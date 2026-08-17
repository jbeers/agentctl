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

- [ ] The operator approves test names, region, size, expected cost, release version, runtime identity, Tailscale enrollment, public package impact, and cleanup plan.
- [ ] The public repository, license, security policy, release assets, checksums, runtime package, documentation URL, and supported-platform statement are reachable without maintainer credentials.
- [ ] The test system does not use the source checkout, development toolchain, private runtime credentials, existing agent bundles, or maintainer shell configuration.
- [ ] The downloaded binary checksum and reported version/source revision match the published release.
- [ ] Existing exact-name provider resources and Tailscale nodes are inspected before mutation.

### First public agent

- [ ] Following the website creates an encrypted V2 bundle with no real credential exposed in the transcript.
- [ ] Redacted inspection and doctor pass using only documented prerequisites.
- [ ] The public default runtime pulls without a registry token.
- [ ] `up` creates fresh exact resources and layered JSON plus text status report ready.
- [ ] Reconciliation reuses the exact Droplet and volume and preserves Hermes health.
- [ ] Interactive SSH and dashboard access work only through the private Tailscale path.
- [ ] Hermes performs a real model-backed task, persists GitHub authentication in its state boundary, and exercises terminal, file, patch, protected-path, and Compose behavior.
- [ ] A sibling service is reachable through `host.containers.internal` and laptop MagicDNS while public-IPv4 access remains blocked.

### Day-two safety

- [ ] A replacement enrollment credential is written through the public rotation workflow without exposing old or new values.
- [ ] After `down`, a cold rebuild consumes the rotated credential, reuses retained state, and discards `/workdir`.
- [ ] State export creates one mode-`0600` validated archive without leaking its path or contents into recorded output.
- [ ] The exported archive restores into a separate fresh agent before Hermes starts and the restored state is usable.
- [ ] Export failure behavior and runtime restart behavior are exercised without leaving partial archives.
- [ ] `down` remains a retained-volume operation and an absent second `down` remains harmless.
- [ ] Purge refuses active, attached, mismatched, duplicate, and unconfirmed test cases before one separately approved exact detached-volume deletion succeeds.

### Website and cleanup

- [ ] Every quickstart link, command, release URL, navigation target, supported default, security statement, persistence warning, and cleanup instruction used during the exercise is correct.
- [ ] Troubleshooting maps every discovered failure to a focused redacted product layer.
- [ ] No VM receives manual configuration or repair; each automation defect gains the smallest deterministic regression before a replacement release is tested.
- [ ] Final cleanup removes every exact test Droplet, volume, Tailscale node, known-host entry, bundle, exported archive, key file, and temporary local or remote file.
- [ ] Evidence records only public release identity, resource identifiers, status, timing, checksums, and redacted failure stages.
- [ ] The public release is labeled alpha and the V3 roadmap marks all completed acceptance criteria in the same change.

## Blocked by

- [002 — Download and verify a Linux agentctl release](002-download-and-verify-linux-agentctl-release.md)
- [003 — Use a supported public runtime by default](003-use-supported-public-runtime-by-default.md)
- [004 — Complete a clean-room first-agent guide](004-complete-clean-room-first-agent-guide.md)
- [005 — Launch the docs-first agentctl website](005-launch-docs-first-agentctl-website.md)
- [006 — Rotate encrypted agent credentials safely](006-rotate-encrypted-agent-credentials-safely.md)
- [007 — Export portable Hermes state](007-export-portable-hermes-state.md)
- [008 — Purge retained state safely](008-purge-retained-state-safely.md)
- [009 — Expose layered status as JSON](009-expose-layered-status-as-json.md)
