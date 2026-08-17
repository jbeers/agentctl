# Security policy

## Project status

`agentctl` is currently pre-public-alpha software. It has completed an operator-approved live acceptance exercise, but it has not received a third-party security audit and does not claim to provide a formally verified security boundary.

Until the first public release, the current development branch receives fixes on a best-effort basis. After public-alpha publication, only the latest public-alpha release will receive security fixes unless a release notice says otherwise.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability or include credentials, encrypted bundle data, provider output, private hostnames, archive contents, or private keys in a report.

Use the repository's **Security → Report a vulnerability** workflow for private disclosure. If that workflow is unavailable, contact the maintainer privately before disclosure; do not substitute a public issue.

Include only the minimum safe information needed to reproduce the problem:

- `agentctl` version or source revision
- supported operator platform
- affected command and redacted failure stage
- expected and observed behavior
- a synthetic reproducer when possible

Never attach a real agent bundle, state archive, environment file, SSH identity, Tailscale key, provider token, registry token, or unredacted command log.

## Normal support

Configuration questions, documentation problems, feature requests, and failures that do not expose a security boundary belong in the normal support channel described in [SUPPORT.md](SUPPORT.md).

## Security boundaries

The supported product boundary is documented in the V2 specification and user guides. In particular:

- Provider authentication and the operator's age identity stay on the operator machine.
- Normal access uses OpenSSH and HTTP over the operator's Tailscale network.
- Hermes controls only the unprivileged `agent` user's rootless Podman socket.
- The cloud firewall has no public inbound rules.
- `/opt/data` is retained working state, not an independent backup.
- `/workdir` and ordinary Compose resources are disposable.

A report that depends on public ingress, arbitrary host scripts, rootful container access, unsupported platforms, a modified runtime image, or bypassing documented credential handling may fall outside the supported threat model, but should still be reported privately if it could affect normal users.
