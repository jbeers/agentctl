# Export portable Hermes state

- **Type:** AFK
- **User stories:** 55–60

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add the safe inverse of `up --state-archive`: export the running agent's durable `/opt/data` into a local archive that the existing validator and fresh-state restore path accept. The command uses the explicit bundle, generated SSH identity, and private Tailscale route. It temporarily quiesces Hermes, flushes writes, creates or streams the archive through restrictive temporary paths, validates the exact local bytes, and restores Hermes health before reporting ordinary success.

The archive contains credentials and history. Treat its path, bytes, entries, and errors with the same trust-boundary discipline as archive import.

## Acceptance criteria

- [x] Export requires an explicit bundle and explicit output path; it never discovers a bundle or invents a backup destination.
- [x] The requested output must not already exist and may not be a directory, symlink, device, or other non-regular target.
- [x] Export requires one exact ready agent with the expected attached volume and private SSH route; absent, provisioning, unhealthy, duplicate, or mismatched resources fail before state mutation.
- [x] Hermes is given a bounded clean stop before filesystem synchronization and archive creation.
- [x] The archive is rooted at `/opt/data`, omits an empty filesystem `lost+found`, and contains no destination wrapper directory.
- [x] Local and remote temporary archive paths use mode `0600`; no archive bytes or entries appear in process arguments or lifecycle output.
- [x] The exact received bytes pass the same path, link, type, and digest validation used by state restore.
- [x] A validated local archive is synchronized and published atomically at mode `0600`.
- [x] Normal output reports completion and durability semantics without listing archive entries; verbose output remains secret-safe.
- [x] Hermes is restarted and gateway/dashboard health is restored before a normal successful return.
- [x] If a valid archive is complete but Hermes restart fails, the command preserves the backup, returns nonzero, and reports the failed runtime layer without leaking content.
- [x] Failures before a valid archive exists remove local and remote partial files and make a bounded attempt to restore the prior Hermes state.
- [x] An exported archive restores through the existing `--state-archive` path into a fresh test directory in deterministic integration tests.
- [x] Tests cover empty and populated state, hidden files, symlinks, hard links, executable modes, destination collision, interruption, transfer failure, validation failure, restart failure, redaction, and cleanup.
- [x] Documentation states that the archive is secret-bearing and that the provider volume remains working storage rather than an independent backup.

## Completion evidence

- `agent export --file <bundle> --output <archive>` requires both explicit paths, validates a previously absent target, and reuses `StatusService` so exact compute, volume identity/attachment, private SSH, container, gateway, and dashboard readiness all pass before stop begins.
- The remote script preflights its mount, tools, running container, empty `lost+found`, and private temporary path. It then gives Hermes a bounded stop, synchronizes `/opt/data`, writes a rootless mode-`0600` tar, and restores container, Tailscale, gateway, and dashboard health. EXIT and signal traps remove partial remote bytes and make a bounded restart attempt.
- SCP receives into a mode-`0600` local temporary file. `ArchiveService.prepare` now accepts a same-filesystem staging directory and applies the existing secure-copy, path/link/type, size, and SHA-256 validator before exclusive atomic publication.
- Normal and verbose formatting omit the requested path, entries, bytes, and digest while stating that the provider volume remains working storage rather than an independent backup.
- The deterministic suite passes 94/94 checks. Export coverage includes ready preflight, populated and empty state, hidden files, symlinks, hard links, executable modes, empty `lost+found`, direct-root extraction, output files/directories/dangling symlinks/devices, concurrent collision, stop/transfer/interruption/validation failures, restart-layer failure with backup preservation, mode `0600`, redaction, and local/remote cleanup.
- Exported fixtures passed the existing state validator and extracted into fresh directories with content, links, and executable mode intact and no wrapper directory.
- The generated remote Bash passed syntax checks and an isolated runtime-container exercise. The real script stopped and restarted the simulated Hermes container in order, produced the expected archive shape and mode, omitted `lost+found`, and restarted through its EXIT trap while deleting a forced partial archive.
- Native compilation and command/help parser smoke checks passed. No live provider, Tailscale, VM, or operator archive was used.
- [Export and restore state archives](../../docs/archives.md) documents command use, readiness, failure preservation, secret-bearing handling, restore compatibility, and the working-volume boundary.

## Blocked by

None — complete.
