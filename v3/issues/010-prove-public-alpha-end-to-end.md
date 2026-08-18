# Prove the public alpha end to end

- **Type:** HITL
- **User stories:** 70–77

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Run a deliberate final public-alpha acceptance exercise from a clean supported system using only the public website, downloadable release artifact, checksum, public default runtime, and normal operator trust roots. Prove the newcomer journey and day-two safety features together. Do not build from a development checkout and do not manually repair a failed test VM; fix, release, and retry the product instead.

All billable creation, public artifact publication, Tailscale enrollment, and persistent-volume deletion requires the operator's explicit review.

## Acceptance criteria

### Approval and public preflight

- [x] The operator approves test names, region, size, expected cost, release version, runtime identity, Tailscale enrollment, public package impact, and cleanup plan.
- [x] The public repository, license, security policy, release assets, checksums, runtime package, documentation URL, and supported-platform statement are reachable without maintainer credentials.
- [x] The test system does not use the source checkout, development toolchain, private runtime credentials, existing agent bundles, or maintainer shell configuration.
- [x] The downloaded binary checksum and reported version/source revision match the published release.
- [x] Existing exact-name provider resources and Tailscale nodes are inspected before mutation.

### First public agent

- [x] Following the website creates an encrypted V2 bundle with no real credential exposed in the transcript.
- [x] Redacted inspection and doctor pass using only documented prerequisites.
- [x] The public default runtime pulls without a registry token.
- [x] `up` creates fresh exact resources and layered JSON plus text status report ready.
- [x] Reconciliation reuses the exact Droplet and volume and preserves Hermes health.
- [x] Interactive SSH and dashboard access work only through the private Tailscale path.
- [x] Hermes performs a real model-backed task, persists GitHub authentication in its state boundary, and exercises terminal, file, patch, protected-path, and Compose behavior.
- [x] A sibling service is reachable through `host.containers.internal` and laptop MagicDNS while public-IPv4 access remains blocked.

### Day-two safety

- [x] A replacement enrollment credential is written through the public rotation workflow without exposing old or new values.
- [x] After `down`, a cold rebuild consumes the rotated credential, reuses retained state, and discards `/workdir`.
- [x] State export creates one mode-`0600` validated archive without leaking its path or contents into recorded output.
- [x] The exported archive restores into a separate fresh agent before Hermes starts and the restored state is usable.
- [x] Export failure behavior and runtime restart behavior are exercised without leaving partial archives.
- [x] `down` remains a retained-volume operation and an absent second `down` remains harmless.
- [x] Purge refuses active, attached, mismatched, duplicate, and unconfirmed test cases before one separately approved exact detached-volume deletion succeeds.

### Website and cleanup

- [x] Every quickstart link, command, release URL, navigation target, supported default, security statement, persistence warning, and cleanup instruction used during the exercise is correct.
- [x] Troubleshooting maps every discovered failure to a focused redacted product layer.
- [x] No VM receives manual configuration or repair; each automation defect gains the smallest deterministic regression before a replacement release is tested.
- [x] Final cleanup removes every exact test Droplet, volume, Tailscale node, known-host entry, bundle, exported archive, key file, and temporary local or remote file.
- [x] Evidence records only public release identity, resource identifiers, status, timing, checksums, and redacted failure stages.
- [x] The public release is labeled alpha and the V3 roadmap marks all completed acceptance criteria in the same change.

## Completion evidence

The public `v0.1.0-alpha.6` Linux `amd64` artifact and checksum were downloaded anonymously and matched the embedded source revision. The operator-approved exercise used isolated homes, public release binaries, the public digest-pinned runtime, explicit V2 bundles, private Tailscale routes, and no source checkout or manual VM repair.

The first clean-room run proved the newcomer workflow and found two product defects: runtime-generated external symlinks prevented export validation, and verbose archive restore output exposed archive metadata. The smallest deterministic regressions were released as alpha5 and alpha6. The replacement run proved portable export with alpha5, alpha6 archive-metadata redaction and fresh pre-start restore, rotated-key cold rebuild, restored state usability, layered status, private-only access, Compose behavior, idempotent teardown, exact detached-volume purge, and complete local/provider/Tailscale cleanup. Evidence retained only public release identity, checksums, resource state, timing, and redacted failure stages.

## Blocked by

- [002 — Download and verify a Linux agentctl release](002-download-and-verify-linux-agentctl-release.md)
- [003 — Use a supported public runtime by default](003-use-supported-public-runtime-by-default.md)
- [004 — Complete a clean-room first-agent guide](004-complete-clean-room-first-agent-guide.md)
- [005 — Launch the docs-first agentctl website](005-launch-docs-first-agentctl-website.md)
- [006 — Rotate encrypted agent credentials safely](006-rotate-encrypted-agent-credentials-safely.md)
- [007 — Export portable Hermes state](007-export-portable-hermes-state.md)
- [008 — Purge retained state safely](008-purge-retained-state-safely.md)
- [009 — Expose layered status as JSON](009-expose-layered-status-as-json.md)
