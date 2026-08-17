# Project status and limitations

`agentctl` is currently a **public alpha**. The V2 lifecycle and cold-rebuild acceptance are complete, verified Linux `amd64` executable and Hermes runtime artifacts are public, and the published-artifact first-agent guide has passed an operator-approved clean-room exercise. The proven Markdown is published at [the agentctl documentation website](https://jbeers.github.io/agentctl/).

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
- Export ready `/opt/data` state into a validated, atomic, portable archive.
- Rotate supported SOPS-encrypted bundle credentials through a write-only, atomic workflow.
- Stop Hermes, flush and unmount state, delete compute, and retain the provider volume.
- Guard exact detached-volume purge behind repeated provider checks and typed confirmation.
- Rebuild disposable compute while preserving `/opt/data` and discarding `/workdir`.

The V2 lifecycle paths passed deterministic tests, the live DigitalOcean/Tailscale exercise, and a separate clean-room exercise using only the public `v0.1.0-alpha.2` release and public runtime. Current-source credential rotation additionally passed deterministic and real-SOPS local acceptance; state export passed deterministic archive round-trip and failure acceptance; guarded purge passed deterministic and native fake-provider acceptance. Purge still awaits its separately approved live deletion, and all three commands await the next published executable. No VM received manual repair.

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
- State export is deliberate and local; there is no automatic schedule, remote backup destination, or provider snapshot workflow.
- `down` deletes the Droplet but deliberately retains the billable volume. Current-source guarded purge awaits operator-approved live deletion before completion; until then, production cleanup remains a separately reviewed provider operation.
- `/workdir`, uncommitted source, and ordinary Compose volumes disappear with the Droplet. Hermes and the operator own Git commit and push safety.
- The published `v0.1.0-alpha.2` executable predates `agent rotate`, `agent export`, and `agent purge`; use the next release for those commands.
- There is no idle shutdown, NAS control plane, admin-agent integration, public ingress, repository manager, or second cloud provider.
- The project has not received a third-party security audit.

## Cost and cleanup

`up` can create billable compute and storage. `down` stops compute billing by deleting the exact Droplet, but the retained volume continues to incur storage charges until the operator deliberately deletes it. Always inspect both exact-name Droplets and `agent-home-<agent-name>` volumes after a test.

Removing the local `agentctl` executable or encrypted bundle does not remove provider resources.

## Roadmaps

- [Completed V2 lifecycle](https://github.com/jbeers/agentctl/blob/main/v2/README.md)
- [Public product roadmap](https://github.com/jbeers/agentctl/blob/main/v3/README.md)

Remaining public-alpha work completes live purge verification, adds JSON status, and runs the final public-alpha end-to-end proof.
