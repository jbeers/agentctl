# Seed a workspace archive during up

- **Type:** AFK
- **User stories:** 37–40, 42–46, 48, 49

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Allow an operator to supply a second local tar archive to `agent up` as the initial contents of `/workdir`. This supports recovery of an uncommitted checkout or intentional workspace seeding while preserving the decision that Hermes—not `agentctl`—owns Git and repository behavior.

Reuse the secure archive validation and transfer path established for Hermes state. Keep destination, emptiness checks, ownership, and user-facing semantics distinct so state and workspace cannot be confused.

## Acceptance criteria

- [x] `agent up` accepts a `--workspace-archive` path as a per-invocation CLI input.
- [x] The archive uses the same validated tar format and local path-resolution rules as `--state-archive`.
- [x] Entries are extracted relative to `/workdir`, with no required wrapper directory.
- [x] Extraction is allowed only when `/workdir` is newly created or empty.
- [x] A non-empty workspace causes a clear failure; files are never merged, silently skipped, or overwritten.
- [x] Workspace extraction finishes before Hermes starts and before any Compose command can run.
- [x] Ownership is normalized so Hermes and rootless sibling-container bind mounts can use the restored files.
- [x] `agentctl` does not inspect Git remotes, branches, dirty state, credentials, or commit history in the archive.
- [x] The command clearly reports that `/workdir` remains disposable after seeding.
- [x] `--state-archive` and `--workspace-archive` can be supplied together and are restored to the correct independent destinations.
- [x] A failure in either archive prevents Hermes startup; successful extraction of one archive is not misreported as complete recovery when the other fails.
- [x] Temporary archive copies are removed on all exit paths and archive contents never appear in output.
- [x] Tests cover workspace-only seeding, both archives together, destination separation, non-empty workspace, unsafe entries through the shared validator, ownership, and failure cleanup.

## Verification

- Workspace-only and combined state/workspace flows use separate restrictive files, remote paths, destinations, and user-facing metadata.
- The generated host script preflights both targets before extraction and keeps both rollback guards active until extraction and ownership normalization succeed.
- Tests include an archived `.git` directory and prove that no Git command runs; live archive seeding remains part of issue 010's approved cold rebuild.

## Blocked by

- [005 — Restore a Hermes state archive during up](005-restore-hermes-state-archive.md)
