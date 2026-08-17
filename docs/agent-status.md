# Check layered agent health

`agent status` reports whether the infrastructure and Hermes runtime described by one explicit bundle are usable:

```bash
agentctl agent status --file agents/sample-agent.agent.yml
```

The command is read-only. It does not create, attach, restart, delete, or otherwise reconcile resources. Checks stop at the first failed dependency while every later layer remains visible as `not checked`.

Status inspects these layers in order:

1. Exact-name DigitalOcean Droplet identity and provider status.
2. Exact working volume, configured region and size, and attachment to that Droplet.
3. OpenSSH reachability over the effective Tailscale MagicDNS hostname and host-side Tailscale health.
4. Rootless Hermes container state.
5. Hermes gateway health on port `8642` through the host's Tailscale address.
6. Dashboard health on port `9119` through the host's Tailscale address.

The summary state is:

- `ready` — every layer is healthy.
- `provisioning` — DigitalOcean still reports a newly provisioning Droplet.
- `absent` — no exact-name Droplet exists; SSH and runtime checks are skipped.
- `unhealthy` — compute is inactive or another checked layer failed.

Exit status is `0` only for `ready`. `absent`, `provisioning`, `unhealthy`, provider failures, and invalid local configuration return nonzero. A provider API failure is reported as indeterminate rather than being mistaken for an absent agent.

Status uses strict existing-host-key verification and never removes or replaces a known-host entry. A mismatch is an access-health failure with guidance to run `agent up`, where exact-name reconciliation owns disposable-host key replacement. The bundle SSH identity uses the same temporary mode-`0600`, validated, cleanup-safe path as other SSH-dependent commands.

No public IPv4 address is queried or used for health checks. Provider and remote command output is reduced to safe layer states; decrypted values, environment files, payloads, and private keys are never shown. Repository checkout, branch, and Git readiness remain Hermes-owned and are explicitly outside infrastructure status.

Use the same intentional temporary hostname override supported by other access commands when needed:

```bash
agentctl agent status \
  --file agents/sample-agent.agent.yml \
  --hostname sample-agent-1 \
  --verbose
```
