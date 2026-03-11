# Issue Automation Architecture Note

## Context and User Goal

The repository needs a GitHub-native automation flow where opening an issue automatically creates a feature branch, generates implementation code using Codex in CI, opens a PR to `Integration`, and closes the issue after merge.

Primary user goal:
- remove manual local AI coding from issue implementation
- keep issue -> branch -> Codex generation -> PR -> merge -> close as one automated pipeline

## Constraints and Non-Functional Requirements

- Must run entirely in GitHub Actions.
- Must target `Integration` as the base branch.
- Must use non-interactive Codex automation via repository secrets.
- Must remain safe under branch protection and permission restrictions.

## Dependency Map

- Frontend surfaces: no direct runtime coupling; changes are issue-driven.
- Backend endpoints/services: no direct runtime coupling; changes are issue-driven.
- Database tables/columns: no direct coupling by workflow itself.
- GitHub platform dependencies include issue events, issue comment commands (`/bootstrap`, `/done`), PR APIs (`create`, `list`, `merge`), branch strategy with `Integration`, workflow write permissions, `OPENAI_API_KEY`, and `openai/codex-action@v1`.

## API Map

Critical:
- `issues.opened` and `issues.reopened` trigger branch + Codex implementation.
- `workflow_dispatch(issue_number)` supports existing open issues.
- `issue_comment.created` with `/bootstrap` starts automation for a specific issue.
- `pulls.create` opens PR targeting `Integration`.
- `pulls.merge` attempts automatic squash merge to `Integration`.
- `issues.update(state=closed)` closes issue after successful merge.
- `issue_comment.created` with `/done` is fallback finalize path.

Deferred:
- issue-classification prompts per label/type
- queue orchestration for large batches (for example 200+ issues)
- confidence scoring and test coverage gates before auto-merge

## Data Flow and Failure Modes

Flow:
1. Issue opens (or `/bootstrap` / manual dispatch) -> derive branch name.
2. Checkout `Integration` -> create/reuse issue branch.
3. Apply deterministic bootstrap script.
4. Run Codex with issue title/body prompt.
5. Commit/push branch -> create PR to `Integration`.
6. Attempt automatic merge to `Integration`.
7. If merge succeeds -> close issue; else comment reason and wait for `/done`.

Failure modes:
- Missing `OPENAI_API_KEY`: job fails early with explicit error.
- PR creation blocked by repository policy: workflow surfaces settings path.
- Auto-merge blocked by checks/conflicts/protection: issue remains open with actionable comment.
- Unauthorized `/bootstrap` or `/done`: workflow rejects non-collaborator command.
