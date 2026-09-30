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


