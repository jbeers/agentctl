# Export portable Hermes state

- **Type:** AFK
- **User stories:** 55–60

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add the safe inverse of `up --state-archive`: export the running agent's durable `/opt/data` into a local archive that the existing validator and fresh-state restore path accept. The command uses the explicit bundle, generated SSH identity, and private Tailscale route. It temporarily quiesces Hermes, flushes writes, creates or streams the archive through restrictive temporary paths, validates the exact local bytes, and restores Hermes health before reporting ordinary success.

The archive contains credentials and history. Treat its path, bytes, entries, and errors with the same trust-boundary discipline as archive import.

## Acceptance criteria

- [ ] Export requires an explicit bundle and explicit output path; it never discovers a bundle or invents a backup destination.
- [ ] The requested output must not already exist and may not be a directory, symlink, device, or other non-regular target.
- [ ] Export requires one exact ready agent with the expected attached volume and private SSH route; absent, provisioning, unhealthy, duplicate, or mismatched resources fail before state mutation.
- [ ] Hermes is given a bounded clean stop before filesystem synchronization and archive creation.
- [ ] The archive is rooted at `/opt/data`, omits an empty filesystem `lost+found`, and contains no destination wrapper directory.
- [ ] Local and remote temporary archive paths use mode `0600`; no archive bytes or entries appear in process arguments or lifecycle output.
- [ ] The exact received bytes pass the same path, link, type, and digest validation used by state restore.
- [ ] A validated local archive is synchronized and published atomically at mode `0600`.
- [ ] Normal output reports completion and durability semantics without listing archive entries; verbose output remains secret-safe.
- [ ] Hermes is restarted and gateway/dashboard health is restored before a normal successful return.
- [ ] If a valid archive is complete but Hermes restart fails, the command preserves the backup, returns nonzero, and reports the failed runtime layer without leaking content.
- [ ] Failures before a valid archive exists remove local and remote partial files and make a bounded attempt to restore the prior Hermes state.
- [ ] An exported archive restores through the existing `--state-archive` path into a fresh test directory in deterministic integration tests.
- [ ] Tests cover empty and populated state, hidden files, symlinks, hard links, executable modes, destination collision, interruption, transfer failure, validation failure, restart failure, redaction, and cleanup.
- [ ] Documentation states that the archive is secret-bearing and that the provider volume remains working storage rather than an independent backup.

## Blocked by

- [001 — Establish the canonical public agentctl project](001-establish-canonical-public-agentctl-project.md)
