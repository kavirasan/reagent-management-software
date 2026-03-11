# reagent-management-software

## Issue Automation Workflow

This repository includes automated issue lifecycle handling via GitHub Actions:

1. When an issue is opened/reopened, a branch is created as `issue/<number>-<slug>`.
2. A bootstrap script runs for setup-related tickets (for example issue `#1` style project initialization).
3. A PR to `main` is created automatically and linked with `Closes #<issue>`.
4. When a repository collaborator comments `/done` on the issue, the linked PR is squashed into `main` and the issue is closed.
5. For already-open issues, run the workflow manually with `issue_number` using `workflow_dispatch`.
6. Alternative for already-open issues: comment `/bootstrap` on that issue to start automation without using the manual input box.

Workflow file:
- `.github/workflows/issue-lifecycle-automation.yml`

Prerequisite repository setting:
- `Settings -> Actions -> General -> Workflow permissions -> Read and write permissions`
- `Settings -> Actions -> General -> Workflow permissions -> Allow GitHub Actions to create and approve pull requests`
