# Reagent Management Software - Codex Context

## Purpose
This folder holds repository-specific context for Codex and automation.
It defines how work should flow and the rules to follow.

## How It Should Work
1. Work starts from a GitHub Issue or Jira ticket.
2. Ticket intake creates a normalized work item.
3. Automation generates a spec from the ticket.
4. Development starts only after the spec is created.
5. Code is implemented against the approved spec.
6. Automated checks run: lint, typecheck, unit, integration, and e2e tests.
7. If all required checks pass, changes are merged to `main` through repository protections.

## Rules
- Every non-trivial change must map to a ticket ID.
- Every ticket must have a spec artifact before implementation.
- Spec is the source of truth for scope and acceptance criteria.
- Do not merge to `main` if any required gate fails.
- Maintain traceability: ticket -> spec -> code -> tests -> merge.
- Keep changes backward compatible unless explicitly approved as breaking.
- Include rollback notes for production-impacting changes.
- Never bypass security, authorization, or audit requirements.
- Keep this context high-level; do not add low-level design details here.

## Definition Of Done
- Ticket exists and is linked.
- Spec exists and is up to date.
- Implementation matches the spec.
- Required automated checks pass.
- Merge to `main` is completed through approved process.

## Scope Of This File
This file is intentionally high-level.
Detailed design and implementation specifics belong in ticket-specific specs.
