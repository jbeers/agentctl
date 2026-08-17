# Prove a cold rebuild end to end

- **Type:** HITL
- **User stories:** 19–21, 27–36, 41–55, 56–68

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Run a deliberate live acceptance exercise against a disposable test agent using only the V2 bundle and shipped automation. This issue adds no speculative framework; it validates that the completed slices compose into the promised product behavior and records any discovered provisioning defect as a reproducible automated fix.

Because this creates billable resources and changes real provider, Tailscale, SSH, and volume state, every live action requires operator review. Do not manually repair the test VM: fix automation, recreate, and retry.

## Acceptance criteria

### Approval and preflight

- [x] The operator approves the test agent name, region, size, expected cost, runtime image tag, Tailscale enrollment, firewall impact, and cleanup plan before creation.
- [x] Existing exact-name Droplets, volumes, firewalls, tags, and Tailscale nodes are inspected before mutation.
- [x] No real credential values are copied into this issue or terminal transcript.
- [x] Local static tests, Bash syntax checks, native build, and whitespace checks pass before live creation.

### Fresh bring-up

- [x] A new V2 bundle can be initialized and inspected with all secret values redacted.
- [x] Doctor passes using only documented operator prerequisites.
- [x] `up` creates a fresh Droplet and provider volume without manual SSH repair.
- [x] A successful `up` corresponds to layered `status` reporting `ready`.
- [x] Re-running `up` reuses the same Droplet and volume and leaves Hermes healthy.

### Runtime and access

- [x] `ssh` opens an interactive session through Tailscale MagicDNS with the generated agent identity.
- [x] `open` reaches the private Hermes dashboard.
- [x] Hermes terminal, file, and patch tools can create and modify files under `/workdir`.
- [x] Hermes state is writable under `/opt/data` while protected credential paths retain Hermes' built-in safeguards.
- [x] A representative Compose stack builds or pulls images, starts sibling containers, and passes its integration health check.
- [x] A sibling bind mount can read a known host `/workdir` file.
- [x] Hermes reaches the sibling through `host.containers.internal`.
- [x] The laptop reaches the sibling through MagicDNS.
- [x] The same service is unreachable through public IPv4.

### Archive paths

- [x] A separate fresh test target can restore a non-secret Hermes state fixture through `--state-archive` before Hermes starts.
- [x] A workspace fixture can be seeded through `--workspace-archive` and edited by Hermes afterward.
- [x] Both archive flags work together and restore to distinct destinations.
- [x] A non-empty target and a deliberately unsafe tar fixture fail without starting Hermes or writing outside the destination.

### Safe removal

- [x] `down` stops Hermes, flushes and unmounts state, deletes compute, and reports the provider volume retained.
- [x] The test confirms `/workdir` is gone with compute and that `agentctl` made no Git claim.
- [x] A second `down` succeeds as an absent no-op.
- [x] Persistent volumes are preserved unless the operator separately authorizes their deletion after inspecting their contents and backup status.
- [x] Temporary local and remote files are absent after the exercise.

### Evidence

- [x] Results record only resource identifiers, status, timings, and redacted failure stages.
- [x] Every manual repair discovered during the exercise is replaced by an automated change and regression check before this issue is considered complete.

## Verification

The operator-approved live exercise completed on 2026-08-17 in `nyc3` with size `s-4vcpu-8gb` and runtime `ghcr.io/jbeers/cloud-agent-coder:sha-be4d343`.

- Final local verification passed 77 TestBox checks, generated-Bash syntax checks, native compilation, and whitespace checks.
- E2E Droplet `592755056` reached layered `ready`; reconciliation reused that exact Droplet and volume with one SSH readiness attempt.
- Cold rebuild Droplet `592755887` reused the retained state volume, preserved `/opt/data`, and discarded `/workdir` plus disposable Compose resources.
- Hermes access passed interactive SSH and dashboard checks. Actual Hermes terminal, write, and patch tools passed under `/workdir`; state writes and a protected-path denial passed under `/opt/data` and the managed config boundary.
- The Compose fixture started a rootless sibling, read its relative `/workdir` bind mount, and answered through `host.containers.internal` and laptop MagicDNS. Public-IPv4 access failed as required.
- Restore Droplet `592756913` restored both non-secret archives before Hermes startup. State and workspace remained distinct, archived Git metadata survived, and Hermes edited the seeded workspace.
- Non-empty restore Droplet `592757396` refused the archive with Hermes absent and retained state unchanged. The unsafe fixture failed before provider mutation and created no escaped file.
- Read-only diagnostics identified every failed stage; no VM received a manual repair. Automated regressions now cover partial-host teardown, native collection/string behavior, rootless working directories and ownership, managed environment ownership, native shell quoting, focused runtime failures, and portable archive metadata validation.
- Final cleanup removed both exact-name Droplets, Tailscale nodes, known-host entries, and—after separate operator approval—volumes `2d4091ff-992c-11f1-8ac3-5a82d57d1373` and `c2ea77e2-9934-11f1-a371-4e6913bb2f59`.

## Blocked by

- [004 — Run Compose from a writable workspace](004-run-compose-from-writable-workdir.md)
- [005 — Restore a Hermes state archive during up](005-restore-hermes-state-archive.md)
- [006 — Seed a workspace archive during up](006-seed-workspace-archive.md)
- [007 — Access a running agent](007-access-running-agent.md)
- [008 — Report layered agent health](008-report-layered-agent-health.md)
- [009 — Take an agent down safely](009-take-agent-down-safely.md)
