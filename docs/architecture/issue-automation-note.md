# Issue Automation Architecture Note

## Context and User Goal

The repository needs a GitHub-native automation flow where a newly created issue immediately gets a working branch and an implementation PR, and when work is marked complete the PR is merged to `main` and the issue is closed.

Primary user goal:
- reduce manual project management overhead for issue execution lifecycle
- keep issue -> branch -> PR -> merge -> close fully connected and auditable

## Constraints and Non-Functional Requirements

- Must use GitHub Actions and repository permissions only.
- Must be idempotent for reopened issues.
- Must avoid privileged merge triggers from non-collaborators.
- Must keep automation deterministic and easy to reason about.

## Dependency Map

- Frontend surfaces: none directly changed at runtime.
- Backend endpoints/services: none directly changed at runtime.
- Database tables/columns: none.
- GitHub platform dependencies:
  - issue events and comments
  - pull request APIs
  - repository `main` branch and branch protection settings
  - `GITHUB_TOKEN` with `contents`, `pull-requests`, and `issues` write permissions

## API Map

Critical:
- `issues.opened` and `issues.reopened` events to create/reuse branch and bootstrap implementation.
- `workflow_dispatch` with `issue_number` to bootstrap existing open issues.
- `issue_comment.created` with `/bootstrap` to bootstrap a specific existing issue without manual workflow input.
- `pulls.create` API to open a PR linked to issue.
- `issue_comment.created` with `/done` command to merge PR and close issue.
- `pulls.merge` and `issues.update(state=closed)` APIs for completion.

Deferred:
- Semantic issue parsing for arbitrary issue types.
- Multi-PR issue support and advanced routing by labels/templates.
- Required check orchestration before merge (currently delegated to branch protection).

## Data Flow and Failure Modes

Flow:
1. Issue opens -> derive branch name from issue metadata.
2. Checkout main -> create/reuse issue branch.
3. Run bootstrap script for known setup issue types.
4. Commit/push branch and create PR with `Closes #<issue>`.
5. Collaborator comments `/done` -> merge linked PR -> close issue.

Failure modes:
- Branch exists but diverged: workflow reuses remote branch and pushes incremental changes.
- No linked open PR on `/done`: workflow comments and exits safely.
- Unauthorized `/done` comment: workflow fails with authorization error.
- Merge blocked by protections/checks: merge API fails and issue remains open for manual resolution.
