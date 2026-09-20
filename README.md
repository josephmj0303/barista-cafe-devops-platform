# Barista Cafe DevOps Platform

A containerized Barista Cafe web application deployed on AWS using Terraform, Docker, GitHub Actions, AWS Systems Manager, Prometheus, Grafana, and CloudWatch.

The project demonstrates an end-to-end DevOps workflow covering infrastructure provisioning, containerization, CI/CD, automated deployment, monitoring, logging, and basic secret management.

---

## Architecture

The platform uses Terraform to provision the AWS infrastructure and GitHub Actions to automate application delivery.

### High-Level Architecture

```text
                           Internet
                              |
                              v
                    +-------------------+
                    |   AWS ALB          |
                    | Application LB     |
                    +---------+----------+
                              |
                              v
                    +-------------------+
                    |    App EC2        |
                    |                   |
                    |  Frontend :8080   |
                    |  Backend  :5000    |
                    +---------+----------+
                              |
                              v
                    +-------------------+
                    |   Amazon RDS       |
                    |   PostgreSQL       |
                    +-------------------+

                    +-------------------+
                    | Monitoring EC2     |
                    |                   |
                    | Prometheus        |
                    | Grafana           |
                    | Node Exporter     |
                    | PostgreSQL        |
                    | Exporter          |
                    +-------------------+

                    CloudWatch
                         ^
                         |
                  EC2 logs / metrics


Developer
    |
    v
 GitHub
    |
    v
GitHub Actions
    |
    +--> Tests
    +--> Dependency Audit
    +--> Docker Build
    +--> Trivy Scan
    +--> Terraform Validation
    |
    v
 Docker Hub
    |
    v
 Staging Deployment
    |
    v
 AWS Systems Manager
    |
    +--> App EC2
    +--> Monitoring EC2
    |
    v
 Production Approval
    |
    v
 Production Deployment
```

---

## Technology Stack

### Application

* Python
* Flask
* PostgreSQL
* HTML/CSS/JavaScript
* Nginx

### Containerization

* Docker
* Docker Compose

### AWS

* Amazon VPC
* Public and private subnets
* Application Load Balancer
* Amazon EC2
* Amazon RDS for PostgreSQL
* AWS Systems Manager
* Amazon CloudWatch
* IAM
* Amazon S3

### Infrastructure as Code

* Terraform
* S3 remote state
* Server-side encrypted Terraform state

### CI/CD

* GitHub Actions
* Docker Hub
* pytest
* pip-audit
* Trivy
* Terraform validation
* GitHub Environments

### Monitoring

* Prometheus
* Grafana
* Node Exporter
* PostgreSQL Exporter
* CloudWatch

---

## Repository Structure

```text
barista-cafe-devops-platform/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── backend/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── .env.example
│   └── tests/
│       ├── test_api.py
│       └── test_health.py
│
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   ├── reservation.html
│   ├── css/
│   ├── js/
│   ├── images/
│   ├── fonts/
│   ├── videos/
│   └── nginx/
│       └── default.conf
│
├── deployment/
│   ├── app/
│   │   ├── barista-cloudwatch-agent.json
│   │   ├── deploy-app.sh
│   │   └── docker-compose.yml
│   │
│   └── monitoring/
│       ├── deploy-monitoring.sh
│       ├── docker-compose.yml
│       ├── grafana-datasource.yml
│       └── prometheus-config.yml
│
├── monitoring/
│   └── prometheus/
│       └── prometheus.yml
│
├── terraform/
│   ├── alb.tf
│   ├── backend.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── rds.tf
│   ├── security.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── terraform.tfvars.example
│
├── docker-compose.yml
├── .gitignore
├── LICENSE
└── README.md
```

---

## Application

The application consists of a frontend and backend.

The frontend is served by Nginx from a Docker container.

The backend runs as a Python application using Gunicorn and communicates with PostgreSQL through the configured database connection.

The application includes:

* Cafe website
* Contact form
* Reservation form
* Backend API
* PostgreSQL persistence
* Health endpoint

Contact and reservation requests are persisted in PostgreSQL.

---

## Containerization

Both application components are containerized.

### Backend

The backend image is built from:

```text
backend/Dockerfile
```

### Frontend

The frontend image is built from:

```text
frontend/Dockerfile
```

### Local Docker Compose

The root `docker-compose.yml` provides the local development configuration.

The AWS deployment configuration is located at:

```text
deployment/app/docker-compose.yml
```

The AWS deployment uses:

```text
josephmj0303/barista-cafe-backend:latest
josephmj0303/barista-cafe-frontend:latest
```

---

## Infrastructure with Terraform

Terraform provisions the AWS infrastructure required by the application.

The infrastructure includes:

* VPC
* Public subnets
* Private subnets
* Internet Gateway
* NAT Gateway
* Security groups
* Application EC2
* Monitoring EC2
* Application Load Balancer
* Amazon RDS PostgreSQL
* IAM roles and instance profiles

The Terraform backend uses an S3 bucket with encryption enabled for remote state storage.

Terraform outputs provide the important deployment values:

```text
app_instance_id
monitoring_instance_id
rds_endpoint
alb_dns_name
alb_url
```

---

## Infrastructure Rebuild

The infrastructure is designed to be recreated using Terraform.

To destroy the current infrastructure:

```bash
terraform -chdir=terraform destroy
```

To recreate it:

```bash
terraform -chdir=terraform apply
```

After `terraform apply`, the new EC2 instances register with AWS Systems Manager.

The EC2 user-data installs the required base components, including:

* Docker
* Docker Compose
* AWS Systems Manager Agent
* Amazon CloudWatch Agent

The deployment pipeline can then deploy the application and monitoring stack to the newly created instances.

This destroy-and-recreate process was tested successfully as part of the project validation.

---

## CI/CD Pipeline

The GitHub Actions workflow is located at:

```text
.github/workflows/ci-cd.yml
```

The pipeline performs the following stages:

```text
Pull Request / Push to main
          |
          v
Test and Security Scan
          |
          +--> pytest
          +--> pip-audit
          +--> Python syntax validation
          +--> Docker Compose validation
          +--> Docker image builds
          +--> Trivy image scans
          |
          v
Terraform Validation
          |
          v
Build and Push Images
          |
          v
Staging Deployment
          |
          v
Production Approval
          |
          v
Production Deployment
```

## Test and Security Checks

The CI stage includes:

### Python tests

```bash
pytest -q backend/tests
```

### Dependency audit

```bash
pip-audit -r requirements.txt
```

### Docker image scanning

Trivy scans both the backend and frontend images for HIGH and CRITICAL vulnerabilities.

Unfixed vulnerabilities are ignored during the scan so that the pipeline can report the findings without unnecessarily blocking the assignment deployment.

### Terraform validation

The workflow runs:

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

---

## Docker Image Publishing

On pushes to `main`, GitHub Actions builds and publishes the application images to Docker Hub.

Both `latest` and commit-specific tags are generated:

```text
barista-cafe-backend:latest
barista-cafe-backend:<commit-sha>

barista-cafe-frontend:latest
barista-cafe-frontend:<commit-sha>
```

---

## Deployment

Application deployment is performed using AWS Systems Manager rather than SSH.

This avoids requiring inbound SSH access to the EC2 instances for the deployment process.

### Application Deployment

The deployment script is:

```text
deployment/app/deploy-app.sh
```

It:

1. Receives the target EC2 instance ID.
2. Receives the RDS endpoint.
3. Receives the database password from the CI/CD secret.
4. Builds the application database connection string.
5. Transfers the Docker Compose configuration through SSM.
6. Creates the application `.env` file on the EC2 instance.
7. Configures the CloudWatch Agent.
8. Validates Docker Compose.
9. Pulls the application images.
10. Starts the application containers.
11. Reports the deployment status.

The script uses `set -e` so that a failed remote deployment step causes the deployment to fail.

---

### Monitoring Deployment

The monitoring deployment script is:

```text
deployment/monitoring/deploy-monitoring.sh
```

The monitoring stack consists of:

```text
Prometheus
    |
    +-- Node Exporter
    |
    +-- PostgreSQL Exporter
    |
    +-- Backend metrics

Grafana
    |
    +-- Prometheus datasource
```

The monitoring stack runs on the dedicated monitoring EC2 instance.

---

## Prometheus

Prometheus collects metrics from:

* Prometheus itself
* Node Exporter
* PostgreSQL Exporter
* Application backend metrics endpoint

The deployment script dynamically configures the ALB DNS name when generating the Prometheus configuration.

---

## Grafana

Grafana is deployed as a Docker container on the monitoring EC2 instance.

The Prometheus datasource is provisioned automatically through:

```text
deployment/monitoring/grafana-datasource.yml
```

This allows Grafana to connect to Prometheus without manually configuring the datasource after deployment.

Grafana dashboards were verified successfully after deployment.

---

## Logging

The project uses Amazon CloudWatch for EC2 logging.

The CloudWatch Agent configuration is located at:

```text
deployment/app/barista-cloudwatch-agent.json
```

The configuration collects:

* Cloud-init logs
* Cloud-init output
* AWS Systems Manager Agent logs
* Docker container logs

The configured CloudWatch log groups include:

```text
/barista/system
/barista/docker
```

CloudWatch log groups and log streams were verified successfully after deployment.

---

## Secret Management

Sensitive values are not committed to the repository.

The database password is stored locally in:

```text
terraform/terraform.tfvars
```

and that file is excluded through `.gitignore`.

For CI/CD, sensitive values are supplied through GitHub Actions Secrets, including:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DB_PASSWORD
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
SLACK_WEBHOOK_URL
```

Terraform state is stored remotely in an encrypted S3 backend.

The repository contains only:

```text
terraform/terraform.tfvars.example
```

for configuration reference.

No production database password or cloud credentials are stored in Git.

---

## GitHub Environments

The workflow uses separate GitHub environments for deployment stages:

```text
staging
production
```

The production environment is protected by a required reviewer.

Therefore, the workflow can deploy to staging automatically, while production requires an explicit approval before the production deployment job proceeds.

---

## Failure Notification

The CI/CD workflow includes a Slack notification job.

If a pipeline stage fails, the workflow sends a notification through the configured Slack webhook.

The notification includes information such as:

* Repository
* Branch
* Workflow
* Run number
* Commit SHA

---

## Verification

The final infrastructure and deployment flow were verified after recreating the AWS infrastructure.

The verification included:

### Infrastructure

* Terraform destroy
* Terraform apply
* New EC2 instances
* SSM connectivity
* CloudWatch Agent installation

### Application

* Frontend container running
* Backend container running
* Application accessible through the ALB
* Contact and reservation functionality
* PostgreSQL connectivity

### Monitoring

* Prometheus running
* Node Exporter running
* PostgreSQL Exporter running
* Grafana running
* Grafana Prometheus datasource
* Grafana dashboard

### Logging

* CloudWatch log group
* CloudWatch log stream
* EC2/Docker logging

### CI/CD

* Automated testing
* Security scanning
* Docker image publishing
* Staging deployment
* Production approval
* Production deployment
* Slack failure notification

---

## Cleanup

To remove the AWS infrastructure created by Terraform:

```bash
terraform -chdir=terraform destroy
```

Review the resources Terraform plans to remove before confirming the operation.

---

## Key DevOps Practices Demonstrated

This project demonstrates the following practical DevOps concepts:

* Infrastructure as Code with Terraform
* Reproducible AWS infrastructure
* Containerized application deployment
* Docker Compose
* CI/CD with GitHub Actions
* Automated testing
* Dependency security scanning
* Container vulnerability scanning
* Docker image publishing
* Staging and production environments
* Production approval gates
* AWS Systems Manager based deployment
* Prometheus monitoring
* Grafana visualization
* PostgreSQL monitoring
* CloudWatch logging
* GitHub Secrets
* Encrypted remote Terraform state
* Failure notifications through Slack

---

## Project Status

The platform has been deployed and validated on AWS using a fresh Terraform-created infrastructure environment.

The complete flow from infrastructure provisioning through application deployment, monitoring, logging, and production release has been tested successfully.
