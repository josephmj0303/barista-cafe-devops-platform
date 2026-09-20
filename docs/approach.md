# Approach Documentation

## 1. Assignment Objective

The objective was to build an end-to-end DevOps platform for the Barista Cafe application, covering:

- Infrastructure provisioning with Terraform on AWS
- Containerized application deployment
- CI/CD with GitHub Actions
- Security and vulnerability scanning
- Staging deployment and production approval
- Infrastructure, application, and database monitoring
- Centralized logging
- Secure handling of deployment secrets
- Reproducible infrastructure and deployment
- Clear technical documentation

The application logic itself was treated as secondary to the DevOps implementation, in line with the assignment guidance.

---

## 2. Application and Containerization

The application consists of:

- Frontend served by Nginx
- Python backend application
- PostgreSQL database hosted on Amazon RDS

The frontend and backend are packaged as Docker images and published to Docker Hub.

For local development, Docker Compose provides a simple way to run the application stack. For AWS deployment, the same container images are pulled onto the application EC2 instance.

The application EC2 runs:

- Frontend container
- Backend container

The backend connects to PostgreSQL on RDS through the private network.

---

## 3. AWS Infrastructure Approach

Terraform is used as the single source of truth for AWS infrastructure.

### Network design

The AWS environment uses:

- One VPC
- Two public subnets across Availability Zones
- Two private subnets across Availability Zones
- Internet Gateway
- Public and private route tables
- Security groups controlling traffic between tiers

The public-facing Application Load Balancer is placed across the public subnets.

The application and monitoring EC2 instances are placed in private subnets while remaining manageable through AWS Systems Manager.

RDS PostgreSQL is placed in private subnets and is not publicly accessible.

### Application tier

A dedicated EC2 instance hosts the application containers.

The ALB forwards HTTP traffic to the application instance on the frontend port.

### Monitoring tier

A separate EC2 instance hosts lightweight monitoring services:

- Prometheus
- Grafana
- Node Exporter
- PostgreSQL Exporter

This keeps monitoring isolated from the application workload.

### Database tier

Amazon RDS for PostgreSQL is used instead of running PostgreSQL inside an application EC2 instance.

This separates application compute from database persistence and provides a managed database service while keeping the database private.

---

## 4. Terraform State Management

Terraform state is stored remotely in an encrypted Amazon S3 backend.

The state is therefore not dependent on a developer's local machine and can be accessed by CI/CD after Terraform initialization.

The repository does not contain the Terraform state file.

Infrastructure outputs expose only the values required by deployment automation, such as:

- Application instance ID
- Monitoring instance ID
- ALB DNS name
- RDS endpoint
- VPC/subnet information

Database passwords are not exposed as Terraform outputs.

---

## 5. Infrastructure Reproducibility

A key design goal was reproducibility.

The infrastructure was explicitly tested using the lifecycle:

```text
terraform destroy
        ↓
terraform init
        ↓
terraform apply
        ↓
fresh AWS infrastructure
        ↓
CI/CD deployment
        ↓
application + monitoring running
```

After recreation, the deployment scripts successfully configured the fresh EC2 instances and deployed the application and monitoring containers.

This validates that deployment does not depend on manual configuration remaining on an old EC2 instance.

---

## 6. Deployment Automation

AWS Systems Manager (SSM) is used for remote deployment instead of SSH.

The deployment scripts:

- Resolve infrastructure values from Terraform
- Receive the database password from GitHub Secrets
- URL-encode the database password when constructing database connection strings
- Transfer the required Compose/configuration content through SSM
- Configure the CloudWatch Agent
- Validate Docker Compose configuration
- Pull the latest images
- Start the containers
- Wait for SSM command completion
- Retrieve deployment output
- Return a non-zero exit code when deployment fails

The deployment scripts use `set -euo pipefail` and the remote command block also fails fast so that deployment errors propagate back to GitHub Actions.

---

## 7. CI/CD Approach

GitHub Actions is used for the complete CI/CD workflow.

### Pull request flow

Pull requests targeting `main` run validation without deploying the application.

The validation stage includes:

- Python dependency installation
- PostgreSQL service container
- Pytest unit/integration tests
- `pip-audit`
- Python syntax validation
- Docker Compose validation
- Backend Docker build
- Frontend Docker build
- Trivy container scanning
- Terraform formatting validation
- Terraform initialization
- Terraform validation

### Main branch flow

A successful push to `main` continues with:

```text
Test & Security Scan
        +
Terraform Validation
        ↓
Build & Push Docker Images
        ↓
Deploy Staging
        ↓
Production Approval
        ↓
Deploy Production
```

Docker images are tagged with both:

- `latest`
- Git commit SHA

This provides a convenient current tag while retaining a commit-specific image reference.

---

## 8. Staging and Production Model

GitHub Environments are used to separate staging and production workflow stages.

The staging environment performs deployment and validation before production.

The production environment is protected with a required manual reviewer.

This assignment implementation uses the same Terraform-managed AWS infrastructure for the deployment stages rather than maintaining two separate AWS environments. The separation is therefore implemented at the CI/CD workflow and approval level.

This keeps the assignment architecture small and cost-conscious while still demonstrating controlled promotion to production.

---

## 9. Monitoring Approach

Monitoring is based on Prometheus and Grafana.

### Infrastructure metrics

Node Exporter provides host-level metrics including:

- CPU usage
- Memory usage
- Disk I/O

### Application metrics

The backend exposes a `/metrics` endpoint.

Prometheus collects application metrics used by Grafana dashboards for:

- HTTP request rate
- HTTP status distribution
- Request latency
- Total requests
- HTTP 5xx error rate

### Database metrics

PostgreSQL Exporter exposes database metrics including:

- PostgreSQL availability
- Active connections
- Transaction activity
- Database/cache-related metrics

Two meaningful Grafana dashboards were created:

1. **Barista Cafe - Application Metrics**
2. **Barista Cafe - Infrastructure and Database**

---

## 10. Logging Approach

Centralized logging is implemented using the CloudWatch Agent.

The application EC2 sends system and Docker/application logs to Amazon CloudWatch Logs.

The resulting log groups include:

- `/barista/system`
- `/barista/docker`

The logs provide visibility into:

- System activity
- Backend application logs
- Nginx/frontend access logs
- Container output
- Prometheus scraping/access activity

This allows troubleshooting without connecting directly to the EC2 host.

---

## 11. Security and Secret Management

Secrets are not committed to the repository.

The implementation uses:

- GitHub Actions Secrets for CI/CD credentials
- GitHub Environment protection for production approval
- An ignored `terraform.tfvars` for local Terraform input
- Restricted `.env` permissions on deployed EC2 instances
- Private subnets for application/monitoring/database resources
- Security groups to restrict network paths
- IAM roles for EC2/SSM/CloudWatch access
- AWS Systems Manager instead of SSH-based deployment

The Terraform backend is encrypted in S3.

The database password is not exposed through Terraform outputs.

---

## 12. Cost Optimization

The infrastructure was deliberately kept small because this is an assignment/demo workload.

Cost-conscious decisions include:

- Small EC2 instance classes
- Small RDS instance class
- Minimal RDS storage
- Lightweight Prometheus/Grafana monitoring
- No unnecessary managed observability services
- Docker Hub used as the image registry
- Reproducible infrastructure that can be destroyed when not required

The architecture is intended for demonstration and validation rather than production-scale traffic.

---

## 13. Validation Strategy

Validation was performed at multiple levels:

### Application

- Application accessible through the ALB
- Frontend and backend containers running
- Contact and reservation requests persisted to PostgreSQL

### Infrastructure

- Terraform initialization
- Terraform validation
- Terraform outputs
- Terraform state inspection
- Fresh infrastructure recreation using destroy/apply
- EC2 health checks
- ALB target health
- RDS availability

### CI/CD

- Successful complete GitHub Actions run
- Production manual approval verified
- Docker images published successfully
- Staging and production deployment steps completed

### Failure handling

A controlled pipeline failure was used to verify Slack notification behavior.

### Observability

- Grafana dashboards verified
- Prometheus metrics verified
- CloudWatch log groups verified
- CloudWatch log streams verified
- Docker/application logs visible in CloudWatch

---

## 14. Why This Architecture

The architecture intentionally favors simplicity and clear ownership:

- Terraform handles infrastructure.
- Docker handles application packaging.
- GitHub Actions handles CI/CD.
- SSM handles remote deployment.
- RDS handles PostgreSQL.
- Prometheus/Grafana handle metrics.
- CloudWatch handles centralized logs.
- GitHub Secrets handle CI/CD secrets.

Each component has a clear responsibility without introducing unnecessary infrastructure for the assignment.
