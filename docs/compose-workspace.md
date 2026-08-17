# Workspace and Compose

Hermes works from `/workdir`, which is the same absolute path on the VM host and inside the Hermes container. The directory is writable by Hermes but lives on disposable Droplet storage. Commit and push work that must survive `agent down`.

Seed a fresh workspace before Hermes starts with `agent up --workspace-archive <tar-path>`. The archive extracts directly under empty `/workdir`; it is never merged into existing files. `agentctl` does not inspect or alter Git metadata in the archive, and seeding does not make the workspace persistent. See [Export and restore state archives](archives.md).

The launcher enforces these deployment-owned settings on every `agent up`:

- Hermes process and local terminal working directory: `/workdir`
- File-tool safe write roots: `/opt/data` and `/workdir`
- Container API: the `agent` user's rootless Podman socket at `/run/podman/podman.sock`
- Compose client: `podman-compose`

Adding `/workdir` as a safe root does not disable Hermes' built-in protected credential and system-path denylist.

## Runtime image contract

The selected runtime image must provide `podman-compose`. After starting Hermes and reaching gateway health, `agent up` verifies the command inside the running container before reporting success.

The supported public Linux `amd64` package is `ghcr.io/jbeers/agentctl`. `runtime-v1` and `sha-ac78d96ecd0fe9b57ca51c930e18a69cc8301abf` identify the published release, while the built-in default pins its exact platform manifest:

```text
ghcr.io/jbeers/agentctl@sha256:28b6b1715c7d55ba50fda783c49d40030ce10a3e901bd7bd5eec2c812621053f
```

The package is public and pulls anonymously. It has no `latest` tag. Its OCI publication includes the canonical source revision, SBOM, and provenance attestations. New bundles may omit `runtime.image` to use this default.

The image contains clients only. It does not run a nested container daemon. Hermes receives no rootful socket, host-root mount, `--privileged`, or broad host sudo access. An operator may still select an immutable private image in the bundle or with `--runtime-image`; the optional registry token is used only by the host's rootless Podman login and is not passed into Hermes or printed.

## Runtime upgrades and rollback

To upgrade or roll back, select an exact supported digest in `runtime.image` or with `--runtime-image`, inspect the resulting plan, and run `agent up` with the same bundle. Reconciliation pulls that image, replaces the Hermes container, waits for gateway health, and verifies `podman-compose` inside the running container before succeeding.

Container replacement retains `/opt/data` on the provider volume. It does not turn `/workdir` into persistent storage: the existing workspace remains on the current Droplet during reconciliation, but is discarded by `down` and any cold rebuild. Commit and push work before replacing disposable compute. Rollback uses the same procedure with the prior digest; never retag an existing runtime release.

## Compose verification fixture

Copy `tests/fixtures/compose-workspace` into `/workdir` or use it as a model for a project stack. From a Hermes terminal:

```bash
cd /workdir/compose-workspace
podman-compose --project-name agentctl-check up --detach
curl --fail --retry 15 --retry-delay 2 --retry-connrefused \
  http://host.containers.internal:18080/known.txt
```

The response is:

```text
agentctl-compose-ok
```

The fixture's `${COMPOSE_WORKSPACE_PATH:-.}:/workspace:ro` bind defaults to relative `.` and demonstrates path parity: the Compose client resolves it inside Hermes to `/workdir/compose-workspace`, and the host rootless Podman daemon sees the same host path. `COMPOSE_WORKSPACE_PATH` exists only to support isolated local runtime-image verification.

From the operator machine, the sibling service is reachable privately through MagicDNS:

```bash
curl --fail --retry 15 --retry-delay 2 --retry-connrefused \
  http://<agent-hostname>:18080/known.txt
```

The managed DigitalOcean firewall has no public inbound rules, so the same port must not be reachable through the Droplet's public IPv4 address.

Clean up from Hermes:

```bash
podman-compose --project-name agentctl-check down --volumes
```

Compose project volumes, including the fixture's `scratch` volume, belong to disposable compute. They are not moved onto the Hermes provider volume automatically.
