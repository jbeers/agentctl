# Restore a Hermes state archive during up

- **Type:** AFK
- **User stories:** 41, 43–49

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Allow an operator to supply one local tar archive to `agent up` as the initial contents of fresh Hermes state. The archive is securely transferred, validated, and extracted relative to `/opt/data` before initial environment seeding or Hermes startup.

This is intentionally a local archive input, not a backup-provider framework. It establishes the restore trust boundary and archive format that a future checkpoint store may target.

## Acceptance criteria

- [ ] `agent up` accepts a `--state-archive` path as a per-invocation CLI input.
- [ ] Relative archive paths resolve from the operator's current working directory, not from inside the agent bundle.
- [ ] The source must be a readable regular tar file; directories and missing files fail before cloud mutation where possible.
- [ ] Archive contents are defined as paths relative to `/opt/data`, with no required wrapper directory.
- [ ] The archive is transferred through restrictive local and remote temporary files without placing content or credentials in command arguments.
- [ ] Validation rejects absolute paths, `..` traversal, unsafe symlink or hard-link targets, device nodes, FIFOs, sockets, and entries that would escape the destination.
- [ ] Extraction is permitted only when the target state directory is newly created or empty.
- [ ] A non-empty state target fails clearly; it is never merged, skipped silently, or overwritten.
- [ ] Extraction completes before `.env` seeding, launcher-owned configuration reconciliation, or Hermes startup.
- [ ] A restored non-empty `.env` remains authoritative and is not replaced by bundle initial values.
- [ ] Missing required initial values may be seeded only when the restored state does not already provide them.
- [ ] Restored ownership and permissions are normalized for the rootless host user and Hermes container UID while preserving usable file modes.
- [ ] Failed validation or extraction prevents Hermes startup and removes partial extracted content when the command created the empty target.
- [ ] Local and remote temporary archive files are removed after success, validation failure, transfer failure, and extraction failure.
- [ ] Verbose output may report archive path, size, digest, and stage but never archive contents.
- [ ] Tests cover a valid state tree, restored `.env`, non-empty target, traversal, absolute path, escaping links, special files, ownership normalization, partial failure cleanup, and secret-safe diagnostics.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
