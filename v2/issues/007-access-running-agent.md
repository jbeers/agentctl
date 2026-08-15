# Access a running agent

- **Type:** AFK
- **User stories:** 14, 15, 50–53

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Complete the human access path for a V2 bundle. The operator can open an interactive SSH repair session and launch the private Hermes dashboard without maintaining a separate identity path or remembering a host address.

Both commands must use the same resolved bundle and MagicDNS hostname as `up`. The encrypted per-agent SSH identity is materialized only for the duration of an SSH-dependent command.

## Acceptance criteria

- [ ] `agent ssh` requires an explicit V2 bundle and connects to the bundle's effective Tailscale hostname.
- [ ] The encrypted SSH private key is written to a unique mode-`0600` temporary file, validated with `ssh-keygen`, passed by path to OpenSSH, and removed after success, interruption, and failure.
- [ ] Private-key material never appears in argv, stdout, stderr, verbose diagnostics, or exception text.
- [ ] SSH runs interactively and preserves terminal I/O.
- [ ] Normal access does not use the Droplet's public IPv4 address.
- [ ] The normal repair target and privilege level are documented consistently; no broad host sudo grant is added to Hermes.
- [ ] `agent ssh` does not automatically delete a mismatched known-host entry. It fails with guidance to reconcile the disposable host through `up`.
- [ ] During `up`, stale host-key replacement is limited to the verified exact-name disposable host being reconciled and then retries strict `accept-new` behavior.
- [ ] `agent open` launches the dashboard at the effective MagicDNS hostname and dashboard port using a supported system browser launcher.
- [ ] `agent open` and `agent ssh` do not require `doctl` when the operation can be completed from resolved bundle data and local access tools.
- [ ] Missing SSH, `ssh-keygen`, browser launcher, key material, or Tailscale hostname produces focused remediation without exposing secrets.
- [ ] Fake-runner tests cover interactive argv, host selection, key cleanup, mismatch behavior, launcher selection, and redaction.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
