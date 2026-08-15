# Run Compose from a writable workspace

- **Type:** AFK
- **User stories:** 29–36

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Complete the coding-runtime path so Hermes can edit `/workdir` with all normal file tools and run a representative Compose integration stack as rootless sibling containers.

The official Hermes image limits file-tool writes to `/opt/data` by default. The V2 launcher owns the deployment-specific correction: both `/opt/data` and `/workdir` are safe write roots, `/workdir` is Hermes' terminal working directory, and the container process also starts there. The runtime image contract must include a verified Compose-compatible command rather than assuming one is inherited from an upstream image.

## Acceptance criteria

- [x] Host and Hermes both expose the workspace at the exact absolute path `/workdir`.
- [x] `/workdir` is writable by Hermes' runtime UID through terminal commands, `write_file`, and `patch`.
- [x] The launcher explicitly sets Hermes safe write roots to `/opt/data` and `/workdir` while retaining Hermes' protected credential-path denylist.
- [x] The launcher reconciles Hermes' canonical local terminal working directory to `/workdir`, including after restored or older persistent state.
- [x] The container process working directory is `/workdir`.
- [x] The runtime image contains a documented and tested Compose-compatible command.
- [x] Hermes receives only the rootless `agent` Podman socket; no nested daemon, rootful socket, `--privileged`, host-root mount, or broad sudo access is added.
- [x] `DOCKER_HOST` and `CONTAINER_HOST` target the mounted rootless socket.
- [x] A representative Compose fixture started from Hermes creates sibling containers successfully.
- [x] A sibling bind mount using a relative project path can read a known file from the host `/workdir`.
- [x] Hermes can reach a sibling's published health endpoint through `host.containers.internal`.
- [x] The operator can reach the same published endpoint through Tailscale MagicDNS.
- [x] The endpoint remains unreachable through the Droplet's public IPv4 address under the managed firewall.
- [x] Compose project volumes are documented as disposable and are not moved into Hermes' persistent state implicitly.
- [x] Automated tests verify launcher arguments, safe-root configuration, terminal cwd reconciliation, path parity, and the Compose client contract without requiring a live Droplet.

## Verification

- Automated launcher, image-contract, and fixture checks pass without a live Droplet.
- A locally built runtime image passed terminal, `write_file`, `patch`, protected-path, managed-cwd, rootless-socket, Compose sibling, bind-mount, and `host.containers.internal` checks.
- The managed firewall and Tailscale-only publication path are covered here structurally; deliberate live network evidence remains part of issue 010.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
