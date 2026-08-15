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

- [ ] The operator approves the test agent name, region, size, expected cost, runtime image tag, Tailscale enrollment, firewall impact, and cleanup plan before creation.
- [ ] Existing exact-name Droplets, volumes, firewalls, tags, and Tailscale nodes are inspected before mutation.
- [ ] No real credential values are copied into this issue or terminal transcript.
- [ ] Local static tests, Bash syntax checks, native build, and whitespace checks pass before live creation.

### Fresh bring-up

- [ ] A new V2 bundle can be initialized and inspected with all secret values redacted.
- [ ] Doctor passes using only documented operator prerequisites.
- [ ] `up` creates a fresh Droplet and provider volume without manual SSH repair.
- [ ] A successful `up` corresponds to layered `status` reporting `ready`.
- [ ] Re-running `up` reuses the same Droplet and volume and leaves Hermes healthy.

### Runtime and access

- [ ] `ssh` opens an interactive session through Tailscale MagicDNS with the generated agent identity.
- [ ] `open` reaches the private Hermes dashboard.
- [ ] Hermes terminal, file, and patch tools can create and modify files under `/workdir`.
- [ ] Hermes state is writable under `/opt/data` while protected credential paths retain Hermes' built-in safeguards.
- [ ] A representative Compose stack builds or pulls images, starts sibling containers, and passes its integration health check.
- [ ] A sibling bind mount can read a known host `/workdir` file.
- [ ] Hermes reaches the sibling through `host.containers.internal`.
- [ ] The laptop reaches the sibling through MagicDNS.
- [ ] The same service is unreachable through public IPv4.

### Archive paths

- [ ] A separate fresh test target can restore a non-secret Hermes state fixture through `--state-archive` before Hermes starts.
- [ ] A workspace fixture can be seeded through `--workspace-archive` and edited by Hermes afterward.
- [ ] Both archive flags work together and restore to distinct destinations.
- [ ] A non-empty target and a deliberately unsafe tar fixture fail without starting Hermes or writing outside the destination.

### Safe removal

- [ ] `down` stops Hermes, flushes and unmounts state, deletes compute, and reports the provider volume retained.
- [ ] The test confirms `/workdir` is gone with compute and that `agentctl` made no Git claim.
- [ ] A second `down` succeeds as an absent no-op.
- [ ] Persistent volumes are preserved unless the operator separately authorizes their deletion after inspecting their contents and backup status.
- [ ] Temporary local and remote files are absent after the exercise.

### Evidence

- [ ] Results record only resource identifiers, status, timings, and redacted failure stages.
- [ ] Every manual repair discovered during the exercise is replaced by an automated change and regression check before this issue is considered complete.

## Blocked by

- [004 — Run Compose from a writable workspace](004-run-compose-from-writable-workdir.md)
- [005 — Restore a Hermes state archive during up](005-restore-hermes-state-archive.md)
- [006 — Seed a workspace archive during up](006-seed-workspace-archive.md)
- [007 — Access a running agent](007-access-running-agent.md)
- [008 — Report layered agent health](008-report-layered-agent-health.md)
- [009 — Take an agent down safely](009-take-agent-down-safely.md)
