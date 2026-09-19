#!/usr/bin/env bash
set -euo pipefail

MONITORING_INSTANCE_ID="${1:?Monitoring instance ID is required}"
RDS_ENDPOINT="${2:?RDS endpoint is required}"
ALB_DNS_NAME="${3:?ALB DNS name is required}"
DB_PASSWORD="${4:?DB password is required}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Preparing monitoring deployment"

ENCODED_PASSWORD=$(DB_PASSWORD="$DB_PASSWORD" python3 -c \
  'import os, urllib.parse; print(urllib.parse.quote_plus(os.environ["DB_PASSWORD"]))')

POSTGRES_EXPORTER_URL="postgresql://barista_admin:${ENCODED_PASSWORD}@${RDS_ENDPOINT}:5432/barista?sslmode=require"

COMPOSE_CONTENT=$(cat "$SCRIPT_DIR/docker-compose.yml")
GRAFANA_DATASOURCE=$(cat "$SCRIPT_DIR/grafana-datasource.yml")

PROMETHEUS_CONFIG=$(sed \
  "s/__ALB_DNS_NAME__/${ALB_DNS_NAME}/g" \
  "$SCRIPT_DIR/prometheus-config.yml")

COMMANDS=$(cat <<EOF
set -e
sudo mkdir -p /opt/barista-monitoring/prometheus
sudo mkdir -p /opt/barista-monitoring/grafana/provisioning/datasources

sudo tee /opt/barista-monitoring/docker-compose.yml > /dev/null <<'COMPOSEEOF'
${COMPOSE_CONTENT}
COMPOSEEOF

sudo tee /opt/barista-monitoring/.env > /dev/null <<'ENVEOF'
DATA_SOURCE_NAME=${POSTGRES_EXPORTER_URL}
ENVEOF

sudo chmod 600 /opt/barista-monitoring/.env

sudo tee /opt/barista-monitoring/prometheus/prometheus.yml > /dev/null <<'PROMEOF'
${PROMETHEUS_CONFIG}
PROMEOF

sudo tee /opt/barista-monitoring/grafana/provisioning/datasources/prometheus.yml > /dev/null <<'GRAFEOF'
${GRAFANA_DATASOURCE}
GRAFEOF

sudo docker compose \
  -f /opt/barista-monitoring/docker-compose.yml \
  config -q

sudo docker compose \
  -f /opt/barista-monitoring/docker-compose.yml \
  pull

sudo docker compose \
  -f /opt/barista-monitoring/docker-compose.yml \
  up -d

sudo docker compose \
  -f /opt/barista-monitoring/docker-compose.yml \
  ps
EOF
)

COMMAND_ID=$(aws ssm send-command \
  --instance-ids "$MONITORING_INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters "commands=$(printf '%s\n' "$COMMANDS" | jq -R -s -c 'split("\n") | map(select(length > 0))')" \
  --comment "Deploy Barista Cafe monitoring" \
  --query "Command.CommandId" \
  --output text)

echo "==> SSM command: $COMMAND_ID"
echo "==> Waiting for monitoring deployment"

aws ssm wait command-executed \
  --command-id "$COMMAND_ID" \
  --instance-id "$MONITORING_INSTANCE_ID"

STATUS=$(aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$MONITORING_INSTANCE_ID" \
  --query "Status" \
  --output text)

echo "==> Deployment status: $STATUS"

aws ssm get-command-invocation \
  --command-id "$COMMAND_ID" \
  --instance-id "$MONITORING_INSTANCE_ID" \
  --query "StandardOutputContent" \
  --output text

if [[ "$STATUS" != "Success" ]]; then
  echo "==> Monitoring deployment failed"

  aws ssm get-command-invocation \
    --command-id "$COMMAND_ID" \
    --instance-id "$MONITORING_INSTANCE_ID" \
    --query "StandardErrorContent" \
    --output text

  exit 1
fi

echo "==> Monitoring deployment completed successfully"
