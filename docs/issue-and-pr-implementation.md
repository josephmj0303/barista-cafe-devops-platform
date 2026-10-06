# Barista Café DevOps Platform
## Retrospective Issue → PR Implementation Guide

This document contains the small repository changes required to create retrospective PRs for the project's 18 GitHub issues.

Each issue should be handled independently:

* Create an issue-specific branch.
* Make the small repository change described below.
* Commit and push the branch.
* Create the corresponding PR.
* Use the supplied PR title and description.
* Include Closes #<issue-number> in the PR description.
* Merge the PR so GitHub automatically closes the issue.

### Note: These issues and PRs are retrospective documentation created after project completion. The changes below should correspond to the actual implementation that already exists in the completed project. Avoid introducing unnecessary architectural changes merely to manufacture commits.

---

## Issue #1
Establish Flask backend and PostgreSQL data layer
Repository steps
1. Verify the existing Flask backend structure, PostgreSQL configuration, models, and API endpoints.
2. Add/update the backend documentation or API comments so the implemented contact and reservation persistence is clearly represented.
3. Commit the documentation/configuration representation of the completed backend implementation.
## PR
Description
## Summary
Completed the Flask backend and PostgreSQL persistence implementation.
- Flask REST API
- Contact and reservation endpoints
- PostgreSQL persistence
- Request validation
- Health endpoint
## Verification
Verified contact and reservation requests are persisted successfully in PostgreSQL.
Closes #1

---

## Issue #2
Fix reservation phone-number validation
Repository steps
1. Update the reservation phone validation pattern to match the corrected implementation already tested during development.
2. Update the related frontend/backend validation documentation if necessary.
3. Verify that a valid reservation can be submitted successfully.
## PR
Description
## Summary
Correct the reservation phone-number validation used by the application.
- Updated phone validation
- Valid reservation requests accepted
- Invalid input remains rejected
## Verification
Confirmed successful reservation submission and PostgreSQL persistence.
Closes #3

---

## Issue #3
Correct PostgreSQL connectivity between Docker services
Repository steps
1. Verify the backend database configuration uses the Docker Compose PostgreSQL service name rather than localhost.
2. Confirm the Compose network allows backend-to-PostgreSQL communication.
3. Validate the backend health endpoint and database connectivity.
## PR
Description
## Summary
Correct backend-to-PostgreSQL connectivity in the Docker Compose environment.
- Use the PostgreSQL Compose service name
- Remove incorrect container-local localhost dependency
- Verify backend/database communication
## Verification
Confirmed the backend connects successfully to PostgreSQL through Docker Compose.
Closes #5

---

## Issue #4
Containerize the Barista Café application
Repository steps
1. Verify the frontend, backend and PostgreSQL services are represented in Docker Compose.
2. Verify Dockerfiles, environment configuration, networking and persistent PostgreSQL storage.
3. Run the complete stack and verify contact/reservation functionality.
## PR
Description
## Summary
Containerize the Barista Café application using Docker Compose.
- Frontend container
- Flask backend container
- PostgreSQL service
- Compose networking
- Persistent database storage
## Verification
Verified the complete application stack and confirmed contact and reservation requests are persisted.
Closes #7

---

## Issue #5
Add backend health endpoint and automated application test
Repository steps
1. Verify the /api/health endpoint returns the expected successful response.
2. Add/update the automated test covering the health endpoint.
3. Execute the test locally.
## PR
Description
## Summary
Add automated validation for the backend health endpoint.
- Validate `/api/health`
- Add automated backend health test
- Provide a lightweight CI smoke test
## Verification
Backend health test passes successfully.
Closes #9

---

## Issue #6
Add CI validation for application and Docker build
Repository steps
1. Verify the GitHub Actions CI workflow runs application tests and required validation.
2. Verify the Docker build is included in CI validation.
3. Confirm CI failures prevent the workflow from proceeding successfully.
## PR
Description
## Summary
Add automated CI validation for the application and Docker build.
- Run backend tests
- Validate application changes
- Build Docker components
- Fail CI when validation fails
## Verification
Validated the GitHub Actions workflow successfully.
Closes #11

---

## Issue #7
Add dependency and container security scanning
Repository steps
1. Verify dependency vulnerability scanning is configured in CI.
2. Verify Trivy container scanning is configured.
3. Confirm security scan results are visible in GitHub Actions.
## PR
Description
## Summary
Add automated security checks to CI.
- Dependency vulnerability scanning
- Trivy container scanning
- CI visibility for security findings
## Verification
Confirmed the security checks execute successfully in GitHub Actions.
Closes #13

---

## Issue #8
Provision AWS infrastructure with Terraform
Repository steps
1. Verify the Terraform configuration for the AWS networking, compute, database, load balancing and security resources.
2. Run Terraform formatting and validation.
3. Review the configuration against the deployed AWS architecture.
## PR
Description
## Summary
Add Terraform-based AWS infrastructure provisioning.
- AWS networking
- EC2 compute
- PostgreSQL database
- Load balancing
- Security configuration
## Verification
Terraform configuration was validated against the deployed AWS environment.
Closes #15

---

## Issue #9
Protect Terraform state and infrastructure secrets
Repository steps
1. Verify Terraform state is configured for controlled remote storage.
2. Verify sensitive values are supplied through variables/secrets rather than committed credentials.
3. Search the repository for accidentally committed secrets or sensitive configuration.
## PR
Description
## Summary
Improve infrastructure secret and Terraform state handling.
- Controlled Terraform state storage
- Externalized sensitive configuration
- Repository secret verification
## Verification
Reviewed the repository and confirmed sensitive credentials are not committed.
Closes #17

---

## Issue #10
Implement AWS application deployment through GitHub Actions
Repository steps
1. Verify the GitHub Actions deployment workflow and AWS authentication configuration.
2. Verify AWS Systems Manager is used for the EC2 deployment path where applicable.
3. Validate a successful deployment from GitHub Actions.
## PR
Description
## Summary
Automate AWS application deployment through GitHub Actions.
- GitHub Actions deployment workflow
- AWS integration
- Systems Manager command execution
- Automated application deployment
## Verification
Successfully validated deployment through the CI/CD workflow.
Closes #19

---

## Issue #11
Make SSM deployment failures propagate correctly
Repository steps
1. Verify SSM command execution status is checked by the deployment workflow.
2. Ensure remote command failures cause the GitHub Actions job to fail.
3. Validate both successful and failed deployment behavior.
## PR
Description
## Summary
Improve deployment reliability by correctly propagating AWS Systems Manager command failures.
- Validate SSM command execution
- Fail the GitHub Actions job on deployment errors
- Improve deployment failure visibility
## Verification
Validated deployment failure handling through the CI/CD workflow.
Closes #21

---

## Issue #12
Add application and infrastructure monitoring
Repository steps
1. Verify Prometheus, Grafana and the configured exporters/metrics collection.
2. Verify infrastructure and application-related dashboards.
3. Validate that Prometheus can scrape the configured targets and Grafana can query the metrics.
## PR
Description
## Summary
Add monitoring for the deployed application and infrastructure.
- Prometheus metrics
- Grafana dashboards
- Infrastructure metrics
- PostgreSQL/application visibility
## Verification
Confirmed Prometheus collection and Grafana dashboard visualization.
Closes #23

---

## Issue #13
Correct Grafana dashboard queries and JSON configuration
Repository steps
1. Correct the Grafana dashboard JSON configuration.
2. Fix the affected PromQL expressions, including the 5xx query.
3. Import/validate the dashboard and confirm the panels display correctly.
## PR
Description
## Summary
Correct Grafana dashboard configuration and PromQL queries.
- Fix dashboard JSON
- Correct PromQL expressions
- Correct HTTP 5xx monitoring
- Validate dashboard panels
## Verification
Dashboard imported successfully and queries returned the expected metrics.
Closes #25

---

## Issue #14
Add centralized application logging
Repository steps
1. Verify application logging configuration.
2. Verify the AWS centralized logging configuration and log collection.
3. Generate application activity and confirm the logs are available centrally.
## PR
Description
## Summary
Add centralized application logging for operational troubleshooting.
- Application logging
- Centralized AWS log collection
- Deployment/runtime visibility
## Verification
Generated application activity and confirmed logs are available through the configured centralized logging destination.
Closes #27

---

## Issue #15
Add deployment failure notification
Repository steps
1. Verify the CI/CD failure notification configuration.
2. Confirm notifications are triggered for failed pipeline/deployment executions.
3. Validate the notification using a controlled failure scenario.
## PR
Description
## Summary
Add notifications for CI/CD deployment failures.
- Failure notification handling
- Actionable pipeline alerts
- Controlled failure verification
## Verification
Confirmed that the configured notification is triggered for failed workflow executions.
Closes #29

---

## Issue #16
Add repository documentation and architecture diagrams
Repository steps
1. Verify the root README and supporting documentation describe the application, DevOps architecture and deployment process.
2. Add/update architecture diagrams and relevant screenshots.
3. Review the documentation against the completed implementation.
## PR
Description
## Summary
Document the completed Barista Café DevOps platform.
- Project architecture
- AWS architecture
- Docker architecture
- CI/CD workflow
- Monitoring and logging
- Deployment documentation
- Architecture diagrams and screenshots
## Verification
Reviewed documentation against the implemented project.
Closes #31

---

## Issue #17
Remove infrastructure-specific identifiers and sensitive artifacts
Repository steps
1. Search tracked project files for AWS instance IDs, credentials, generated state files and other environment-specific values.
2. Remove or replace values that should not be committed.
3. Repeat the repository search and verify the final repository is clean.
## PR
Description
## Summary
Perform the final repository security and cleanup review.
- Search for infrastructure-specific identifiers
- Remove unnecessary environment-specific values
- Verify generated/sensitive artifacts are excluded
- Recheck tracked project files
## Verification
Completed repository searches and confirmed the final source tree does not unnecessarily expose environment-specific identifiers.
Closes #33

---

## Issue #18
Perform final end-to-end project verification
Repository steps
1. Perform the final application, Docker, CI/CD, AWS, monitoring, logging and security verification.
2. Update the project verification/checklist documentation with the completed checks.
3. Confirm the repository is ready for final assignment submission.
## PR
Description
## Summary
Complete the final verification pass for the Barista Café DevOps platform.
- Application functionality verified
- Docker deployment verified
- CI/CD verified
- AWS infrastructure verified
- Monitoring and logging verified
- Repository security reviewed
- Documentation reviewed
## Verification
Completed the final end-to-end verification of the project and assignment deliverables.
Closes #35
