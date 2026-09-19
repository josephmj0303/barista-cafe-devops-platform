#!/usr/bin/env bash
set -euo pipefail

APP_INSTANCE_ID="${1:?App instance ID is required}"
RDS_ENDPOINT="${2:?RDS endpoint is required}"
DB_PASSWORD="${3:?DB password is required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Preparing application deployment"

ENCODED_PASSWORD=$(DB_PASSWORD="$DB_PASSWORD" python3 -c \
  'import os, urllib.parse; print(urllib.parse.quote_plus(os.environ["DB_PASSWORD"]))')

DATABASE_URL="postgresql+psycopg://barista_admin:${ENCODED_PASSWORD}@${RDS_ENDPOINT}:5432/barista"

COMPOSE_CONTENT=$(cat "$SCRIPT_DIR/docker-compose.yml")
CLOUDWATCH_CONFIG=$(cat "$SCRIPT_DIR/barista-cloudwatch-agent.json")

COMMANDS=$(cat <<EOF
sudo mkdir -p /opt/barista
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/etc

sudo tee /opt/barista/docker-compose.yml > /dev/null <<'COMPOSEEOF'
${COMPOSE_CONTENT}
COMPOSEEOF

sudo tee /opt/barista/.env > /dev/null <<'ENVEOF'
DATABASE_URL=${DATABASE_URL}
ENVEOF

sudo chmod 600 /opt/barista/.env

sudo tee /opt/aws/amazon-cloudwatch-agent/etc/barista-cloudwatch-agent.json > /dev/null <<'CWEOF'
${CLOUDWATCH_CONFIG}
CWEOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/barista-cloudwatch-agent.json \
  -s

sudo docker compose \
  -f /opt/barista/docker-compose.yml \
  config -q

sudo docker compose \
  -f /opt/barista/docker-compose.yml \
  pull

sudo docker compose \
  -f /opt/barista/docker-compose.yml \
  up -d

sudo docker compose \
  -f /opt/barista/docker-compose.yml \
  ps
EOF
)

COMMAND_ID=$(aws ssm send-command \
  --instance-ids "$APP_INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters "commands=$(printf '%s\n' "$COMMANDS" | jq -R -s -c 'split("\n") | map(select(length > 0))')" \
  --comment "Deploy Barista Cafe application" \
  --query "Command.CommandId" \
  --output text)

echo "==> SSM command: $COMMAND_ID"
echo "==> Waiting for application deployment"

aws ssm wait command-executed \
  --command-id "$COMMAND_ID" \
  --instance-id "$APP_INSTANCE_ID"

STATUS=$(aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$APP_INSTANCE_ID" \
  --query "Status" \
  --output text)

echo "==> Deployment status: $STATUS"

aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$APP_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text

if [[ "$STATUS" != "Success" ]]; then
  echo "==> Application deployment failed"

  aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$APP_INSTANCE_ID" \
    --query "StandardErrorContent" \
    --output text

  exit 1
fi

echo "==> Application deployment completed successfully"
