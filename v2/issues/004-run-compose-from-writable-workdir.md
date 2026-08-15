# Run Compose from a writable workspace

- **Type:** AFK
- **User stories:** 29–36

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Complete the coding-runtime path so Hermes can edit `/workdir` with all normal file tools and run a representative Compose integration stack as rootless sibling containers.

The official Hermes image limits file-tool writes to `/opt/data` by default. The V2 launcher owns the deployment-specific correction: both `/opt/data` and `/workdir` are safe write roots, `/workdir` is Hermes' terminal working directory, and the container process also starts there. The runtime image contract must include a verified Compose-compatible command rather than assuming one is inherited from an upstream image.

## Acceptance criteria

- [ ] Host and Hermes both expose the workspace at the exact absolute path `/workdir`.
- [ ] `/workdir` is writable by Hermes' runtime UID through terminal commands, `write_file`, and `patch`.
- [ ] The launcher explicitly sets Hermes safe write roots to `/opt/data` and `/workdir` while retaining Hermes' protected credential-path denylist.
- [ ] The launcher reconciles Hermes' canonical local terminal working directory to `/workdir`, including after restored or older persistent state.
- [ ] The container process working directory is `/workdir`.
- [ ] The runtime image contains a documented and tested Compose-compatible command.
- [ ] Hermes receives only the rootless `agent` Podman socket; no nested daemon, rootful socket, `--privileged`, host-root mount, or broad sudo access is added.
- [ ] `DOCKER_HOST` and `CONTAINER_HOST` target the mounted rootless socket.
- [ ] A representative Compose fixture started from Hermes creates sibling containers successfully.
- [ ] A sibling bind mount using a relative project path can read a known file from the host `/workdir`.
- [ ] Hermes can reach a sibling's published health endpoint through `host.containers.internal`.
- [ ] The operator can reach the same published endpoint through Tailscale MagicDNS.
- [ ] The endpoint remains unreachable through the Droplet's public IPv4 address under the managed firewall.
- [ ] Compose project volumes are documented as disposable and are not moved into Hermes' persistent state implicitly.
- [ ] Automated tests verify launcher arguments, safe-root configuration, terminal cwd reconciliation, path parity, and the Compose client contract without requiring a live Droplet.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
