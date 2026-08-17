# Project status and limitations

`agentctl` is currently a **public alpha**. The V2 lifecycle and cold-rebuild acceptance are complete, verified Linux `amd64` executable and Hermes runtime artifacts are public, and the published-artifact first-agent guide has passed an operator-approved clean-room exercise. The documentation website is being launched from that proven Markdown.

## What is proven

The completed implementation can:

- Initialize, inspect, and diagnose one explicit partially encrypted V2 bundle.
- Create or reconcile an Ubuntu 24.04 DigitalOcean Droplet and retained Block Storage volume.
- Enroll the host in Tailscale and keep public inbound firewall rules empty.
- Run Hermes as an unprivileged user with a rootless Podman socket.
- Report provider, volume, SSH, container, gateway, and dashboard health.
- Open private SSH repair access and the Hermes dashboard.
- Run Hermes terminal, file, patch, and rootless Compose workflows under `/workdir`.
- Restore validated state and workspace archives into separate empty destinations.
- Stop Hermes, flush and unmount state, delete compute, and retain the provider volume.
- Rebuild disposable compute while preserving `/opt/data` and discarding `/workdir`.

These paths passed deterministic tests, the V2 live DigitalOcean/Tailscale exercise, and a separate clean-room exercise using only the public `v0.1.0-alpha.2` release and public runtime. No VM received manual repair.

## Current supported boundary

- **Agent runtime:** public digest-pinned `ghcr.io/jbeers/agentctl` image, Hermes only
- **Compute provider:** DigitalOcean only
- **VM host:** Ubuntu 24.04, Linux `amd64`
- **Operator artifact:** verified native Linux `amd64` release
- **Private access:** operator-managed Tailscale with MagicDNS
- **Containers:** rootless Podman sibling containers; no nested or rootful daemon
- **Working state:** one DigitalOcean Block Storage volume mounted at `/opt/data`
- **Workspace:** disposable Droplet storage at `/workdir`

## Important limitations

- Linux `amd64` is the only supported operator release target.
- The retained provider volume is durable working storage, **not an independent backup**.
- State archives can be restored, but `agentctl` cannot yet export state.
- `down` deletes the Droplet but deliberately retains the billable volume. Complete volume deletion currently requires a separately reviewed provider operation; guarded purge is roadmap work.
- `/workdir`, uncommitted source, and ordinary Compose volumes disappear with the Droplet. Hermes and the operator own Git commit and push safety.
- Enrollment and registry credentials cannot yet be rotated through `agentctl`; use SOPS directly with appropriate care until rotation is implemented.
- There is no idle shutdown, NAS control plane, admin-agent integration, public ingress, repository manager, or second cloud provider.
- The project has not received a third-party security audit.

## Cost and cleanup

`up` can create billable compute and storage. `down` stops compute billing by deleting the exact Droplet, but the retained volume continues to incur storage charges until the operator deliberately deletes it. Always inspect both exact-name Droplets and `agent-home-<agent-name>` volumes after a test.

Removing the local `agentctl` executable or encrypted bundle does not remove provider resources.

## Roadmaps

- [Completed V2 lifecycle](https://github.com/jbeers/agentctl/blob/main/v2/README.md)
- [Public product roadmap](https://github.com/jbeers/agentctl/blob/main/v3/README.md)

Remaining public-alpha work launches the documentation website and adds credential rotation, state export, guarded purge, and JSON status.
