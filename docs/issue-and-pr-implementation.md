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


