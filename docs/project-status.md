# Project status and limitations

`agentctl` is currently a **public alpha**. The V2 lifecycle, cold-rebuild acceptance, and final public-alpha exercise are complete. Verified Linux `amd64` executable and Hermes runtime artifacts are public, and the proven Markdown is published at [the agentctl documentation website](https://jbeers.github.io/agentctl/).

## What is proven

The completed implementation can:

- Initialize, inspect, and diagnose one explicit partially encrypted V2 bundle.
- Create or reconcile an Ubuntu 24.04 DigitalOcean Droplet and retained Block Storage volume.
- Enroll the host in Tailscale and keep public inbound firewall rules empty.
- Run Hermes as an unprivileged user with a rootless Podman socket.
- Report provider, volume, SSH, container, gateway, and dashboard health as human text or versioned JSON.
- Open private SSH repair access and the Hermes dashboard.
- Run Hermes terminal, file, patch, and rootless Compose workflows under `/workdir`.
- Restore validated state and workspace archives into separate empty destinations.
- Export ready `/opt/data` state into a validated, atomic, portable archive.
- Rotate supported SOPS-encrypted bundle credentials through a write-only, atomic workflow.
- Stop Hermes, flush and unmount state, delete compute, and retain the provider volume.
- Guard exact detached-volume purge behind repeated provider checks and typed confirmation.
- Rebuild disposable compute while preserving `/opt/data` and discarding `/workdir`.

The V2 lifecycle paths passed deterministic tests, the live DigitalOcean/Tailscale exercise, and replacement clean-room exercises using only public release artifacts and the public runtime. The final exercise proved provisioning, private access, model inference, GitHub authentication, Compose, protected-path behavior, write-only credential rotation, cold rebuild, portable export and restore, idempotent teardown, guarded purge, and complete cleanup. A live export failure caused by runtime symlink exclusion paths was fixed in `v0.1.0-alpha.5`; a separate verbose archive-metadata disclosure was fixed and re-tested in `v0.1.0-alpha.6`. No VM received manual repair. The published alpha6 artifact, checksum, source revision, documentation website, and public runtime were independently verified.

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
- `down` deletes the Droplet but deliberately retains the billable volume. Guarded purge has passed live exact-volume deletion, but remains irreversible and requires separate review of identity, attachment, and backup status every time.
- `/workdir`, uncommitted source, and ordinary Compose volumes disappear with the Droplet. Hermes and the operator own Git commit and push safety.
- `v0.1.0-alpha.6` is the current supported public release. Earlier alpha artifacts are unsupported; use the latest exact release and verify its checksum before operation.
- There is no idle shutdown, NAS control plane, admin-agent integration, public ingress, repository manager, or second cloud provider.
- The project has not received a third-party security audit.

## Cost and cleanup

`up` can create billable compute and storage. `down` stops compute billing by deleting the exact Droplet, but the retained volume continues to incur storage charges until the operator deliberately deletes it. Always inspect both exact-name Droplets and `agent-home-<agent-name>` volumes after a test.

Removing the local `agentctl` executable or encrypted bundle does not remove provider resources.

## Roadmaps

- [Completed V2 lifecycle](https://github.com/jbeers/agentctl/blob/main/v2/README.md)
- [Public product roadmap](https://github.com/jbeers/agentctl/blob/main/v3/README.md)

The V3 public-alpha roadmap is complete. Future work remains deliberately unticketed until real usage requires additional backup destinations, idle shutdown, hosted administration, more operator platforms, or another compute provider.
