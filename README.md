# reagent-management-software

## Issue Automation Workflow

This repository includes automated issue lifecycle handling via GitHub Actions:

1. On `issues.opened/reopened`, a feature branch is created as `issue/<number>-<slug>` from `Integration`.
2. Codex runs in CI (`openai/codex-action`) using issue title/body as implementation input.
3. Changes are committed and a PR targeting `Integration` is created automatically.
4. Workflow attempts automatic squash merge into `Integration`.
5. If automatic merge succeeds, issue is closed automatically.
6. If merge is blocked by protections/checks/conflicts, workflow comments status and a collaborator can finalize with `/done`.

For already-open issues:
- Run workflow manually with `issue_number` (`workflow_dispatch`).
- Or comment `/bootstrap` on that issue.

Workflow file:
- `.github/workflows/issue-lifecycle-automation.yml`

Prerequisite repository setting:
- `Settings -> Actions -> General -> Workflow permissions -> Read and write permissions`
- `Settings -> Actions -> General -> Workflow permissions -> Allow GitHub Actions to create and approve pull requests`

Required secret:
- `Settings -> Secrets and variables -> Actions -> OPENAI_API_KEY`
