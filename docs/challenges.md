# Challenges and Resolutions

This document records the main technical issues encountered during the assignment and the changes made to resolve them.

---

## 1. CloudWatch Agent Missing on the Initial Deployment

### Problem

The first deployment attempt failed because the application EC2 instance did not have the Amazon CloudWatch Agent installed.

The deployment script attempted to execute:

```text
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl
```

but the binary was not present.

### Root Cause

The existing EC2 instance had been created before the CloudWatch Agent installation was added to the Terraform user-data configuration.

The deployment script and the infrastructure bootstrap were therefore out of sync.

### Resolution

CloudWatch Agent installation was moved into the Terraform EC2 bootstrap process.

The EC2 user-data now installs:

```text
docker
amazon-cloudwatch-agent
```

The infrastructure was then destroyed and recreated instead of manually patching the old instance.

### Validation

After recreation:

- CloudWatch Agent was present on the fresh application instance.
- CloudWatch configuration succeeded.
- Logs appeared in CloudWatch.
- The application deployment completed successfully.

### Lesson

Infrastructure dependencies required by deployment scripts should be established by infrastructure provisioning rather than relying on manual host configuration.

---

## 2. Remote SSM Deployment Did Not Initially Fail Fast

### Problem

The deployment scripts used AWS Systems Manager to execute multiple commands remotely.

During troubleshooting, it became clear that an error in an earlier remote command could allow subsequent commands to execute unless the remote shell was configured to stop on failure.

### Resolution

The remote SSM command block was changed to use:

```bash
set -e
```

The local deployment scripts use:

```bash
set -euo pipefail
```

The scripts also wait for the SSM command to finish, retrieve its status, print stdout/stderr, and return a non-zero exit code when the remote deployment fails.

### Result

Deployment failures now propagate correctly to GitHub Actions, allowing the workflow to fail and the Slack notification job to run.

### Lesson

A remote deployment script should explicitly propagate failure status to the CI/CD system.

---

## 3. Database Password Characters in Connection Strings

### Problem

The PostgreSQL password is supplied through GitHub Secrets.

Special characters in a password can have special meaning inside a URI and can therefore break the database connection string.

### Resolution

The deployment scripts URL-encode the password before constructing:

```text
DATABASE_URL
```

and the PostgreSQL Exporter connection string.

Python's `urllib.parse.quote_plus()` is used for this encoding.

### Result

The same deployment mechanism works without requiring passwords to be restricted to a small set of characters.

### Lesson

Credentials embedded in connection URIs must be encoded correctly rather than concatenated blindly.

---

## 4. Reproducibility of Fresh EC2 Instances

### Problem

A deployment can work on an existing server because that server contains configuration left behind by previous manual work.

That would not satisfy the intended Terraform lifecycle requirement.

### Resolution

The infrastructure was deliberately destroyed and recreated.

The deployment was then executed against the fresh EC2 instances.

The deployment scripts created the required directories, configuration files, CloudWatch configuration, Docker Compose configuration, and containers automatically.

### Result

The fresh environment successfully reached the expected state.

### Lesson

A reproducible deployment should depend on code and infrastructure definitions, not undocumented manual host changes.

---

## 5. Separating Deployment Logic from the GitHub Actions Workflow

### Problem

The initial workflow contained large blocks of inline SSM shell commands.

This made the workflow difficult to read and harder to maintain.

### Resolution

Deployment logic was moved into:

```text
deployment/app/deploy-app.sh
deployment/monitoring/deploy-monitoring.sh
```

GitHub Actions now calls these scripts after resolving the required Terraform outputs and secrets.

### Result

The workflow is easier to understand and the deployment logic can also be tested independently.

### Lesson

CI/CD workflow files should orchestrate deployment rather than contain large amounts of application-specific shell logic.

---

## 6. Production Approval Testing

### Problem

The assignment required a manual production approval step.

A pipeline that simply deploys directly from staging to production would not demonstrate this requirement.

### Resolution

A protected GitHub `production` environment was configured with a required reviewer.

The workflow pauses after staging and displays a production deployment approval request.

### Result

The approval gate was successfully observed in GitHub Actions before production deployment continued.

### Lesson

Environment protection rules provide a simple way to implement controlled production promotion without adding another deployment platform.

---

## 7. Slack Failure Notification Validation

### Problem

The Slack notification path needs to be tested independently from the normal successful deployment path.

### Resolution

A controlled workflow failure was triggered during testing.

The failure notification job was configured with:

```yaml
if: always() && contains(needs.*.result, 'failure')
```

The Slack webhook received the expected notification containing repository, branch, workflow, run, and commit information.

The temporary test modification was then reverted so the final repository retained the normal CI/CD implementation.

### Result

The failure notification mechanism was verified without leaving artificial failure logic in the final workflow.

### Lesson

Failure paths should be deliberately tested, then temporary test changes should be removed before final submission.

---

## 8. Keeping the Infrastructure Within Assignment Scope

### Problem

There are many additional AWS services that could be introduced, but doing so would increase cost and operational complexity without directly satisfying the assignment.

### Resolution

The final architecture deliberately uses a small set of components:

- VPC
- ALB
- EC2
- RDS
- SSM
- CloudWatch
- Prometheus
- Grafana
- GitHub Actions
- Docker Hub

No additional major platform was introduced merely for complexity.

### Result

The final design demonstrates the required DevOps capabilities while remaining understandable and cost-conscious.

### Lesson

Good DevOps design is not about maximizing the number of services. Each component should have a clear purpose.

---

## 9. Final Documentation and Evidence

### Problem

The assignment evaluates not only implementation but also the ability to explain the approach and demonstrate the result.

### Resolution

The final repository includes:

- Main README
- Architecture diagrams
- Approach documentation
- Challenges and resolutions
- CI/CD evidence
- Monitoring screenshots
- Logging screenshots
- Application screenshot

### Result

The implementation can be reviewed through both source code and visual evidence.

### Lesson

A technically correct implementation is stronger when the architecture, decisions, validation, and troubleshooting process are clearly documented.
