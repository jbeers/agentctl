# Report layered agent health

- **Type:** AFK
- **User stories:** 6, 7, 21, 39, 54, 55

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Make `agent status` answer whether an agent is actually usable instead of reporting only that a Droplet exists. The command should inspect each meaningful layer in dependency order and produce a concise, redacted summary suitable for a human operator.

This remains a read-only command. It may use provider queries and SSH health checks but must not attach storage, restart containers, replace host keys, or otherwise reconcile state.

## Acceptance criteria

- [x] `agent status` resolves one explicit V2 bundle and performs no mutation.
- [x] An absent Droplet is reported as `absent` without attempting SSH or remote checks.
- [x] A present agent reports compute identity/status, effective Tailscale hostname, working-volume attachment, SSH/Tailscale reachability, Hermes container state, gateway health, and dashboard health.
- [x] The summary distinguishes at least `absent`, `provisioning`, `ready`, and `unhealthy`.
- [x] A failed layer identifies the boundary and preserves useful non-secret error detail without dumping payloads, environment files, or decrypted bundle values.
- [x] Status does not replace stale SSH host keys; an identity mismatch is reported as an access-health failure with recovery guidance.
- [x] Exit status is documented and stable: zero only for `ready`, nonzero for absent, provisioning, unhealthy, or invalid local configuration.
- [x] Provider API failure is distinguishable from an absent Droplet.
- [x] Hermes health is checked through the private route rather than public IPv4.
- [x] Output reminds the operator that repository readiness is Hermes-owned and is not part of infrastructure health.
- [x] Verbose mode may show command stages and targets but not secrets.
- [x] Fake-runner tests cover every reported state, short-circuit ordering, provider errors, access errors, unhealthy endpoints, exit status, and redaction.

## Verification

- Provider checks use only exact-name list/get operations; strict SSH host-key checking prevents status from changing known-host state.
- Remote checks short-circuit through Tailscale, rootless Hermes container state, gateway health, and dashboard health without querying public IPv4.
- Tests cover all four summary states, each failed boundary, stable exit codes, temporary identity cleanup, provider/access error sanitization, and generated Bash syntax.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
