# Seed a workspace archive during up

- **Type:** AFK
- **User stories:** 37–40, 42–46, 48, 49

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Allow an operator to supply a second local tar archive to `agent up` as the initial contents of `/workdir`. This supports recovery of an uncommitted checkout or intentional workspace seeding while preserving the decision that Hermes—not `agentctl`—owns Git and repository behavior.

Reuse the secure archive validation and transfer path established for Hermes state. Keep destination, emptiness checks, ownership, and user-facing semantics distinct so state and workspace cannot be confused.

## Acceptance criteria

- [ ] `agent up` accepts a `--workspace-archive` path as a per-invocation CLI input.
- [ ] The archive uses the same validated tar format and local path-resolution rules as `--state-archive`.
- [ ] Entries are extracted relative to `/workdir`, with no required wrapper directory.
- [ ] Extraction is allowed only when `/workdir` is newly created or empty.
- [ ] A non-empty workspace causes a clear failure; files are never merged, silently skipped, or overwritten.
- [ ] Workspace extraction finishes before Hermes starts and before any Compose command can run.
- [ ] Ownership is normalized so Hermes and rootless sibling-container bind mounts can use the restored files.
- [ ] `agentctl` does not inspect Git remotes, branches, dirty state, credentials, or commit history in the archive.
- [ ] The command clearly reports that `/workdir` remains disposable after seeding.
- [ ] `--state-archive` and `--workspace-archive` can be supplied together and are restored to the correct independent destinations.
- [ ] A failure in either archive prevents Hermes startup; successful extraction of one archive is not misreported as complete recovery when the other fails.
- [ ] Temporary archive copies are removed on all exit paths and archive contents never appear in output.
- [ ] Tests cover workspace-only seeding, both archives together, destination separation, non-empty workspace, unsafe entries through the shared validator, ownership, and failure cleanup.

## Blocked by

- [005 — Restore a Hermes state archive during up](005-restore-hermes-state-archive.md)
