# Report layered agent health

- **Type:** AFK
- **User stories:** 6, 7, 21, 39, 54, 55

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Make `agent status` answer whether an agent is actually usable instead of reporting only that a Droplet exists. The command should inspect each meaningful layer in dependency order and produce a concise, redacted summary suitable for a human operator.

This remains a read-only command. It may use provider queries and SSH health checks but must not attach storage, restart containers, replace host keys, or otherwise reconcile state.

## Acceptance criteria

- [ ] `agent status` resolves one explicit V2 bundle and performs no mutation.
- [ ] An absent Droplet is reported as `absent` without attempting SSH or remote checks.
- [ ] A present agent reports compute identity/status, effective Tailscale hostname, working-volume attachment, SSH/Tailscale reachability, Hermes container state, gateway health, and dashboard health.
- [ ] The summary distinguishes at least `absent`, `provisioning`, `ready`, and `unhealthy`.
- [ ] A failed layer identifies the boundary and preserves useful non-secret error detail without dumping payloads, environment files, or decrypted bundle values.
- [ ] Status does not replace stale SSH host keys; an identity mismatch is reported as an access-health failure with recovery guidance.
- [ ] Exit status is documented and stable: zero only for `ready`, nonzero for absent, provisioning, unhealthy, or invalid local configuration.
- [ ] Provider API failure is distinguishable from an absent Droplet.
- [ ] Hermes health is checked through the private route rather than public IPv4.
- [ ] Output reminds the operator that repository readiness is Hermes-owned and is not part of infrastructure health.
- [ ] Verbose mode may show command stages and targets but not secrets.
- [ ] Fake-runner tests cover every reported state, short-circuit ordering, provider errors, access errors, unhealthy endpoints, exit status, and redaction.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
