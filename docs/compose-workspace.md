# Workspace and Compose

Hermes works from `/workdir`, which is the same absolute path on the VM host and inside the Hermes container. The directory is writable by Hermes but lives on disposable Droplet storage. Commit and push work that must survive `agent down`.

Seed a fresh workspace before Hermes starts with `agent up --workspace-archive <tar-path>`. The archive extracts directly under empty `/workdir`; it is never merged into existing files. `agentctl` does not inspect or alter Git metadata in the archive, and seeding does not make the workspace persistent. See [Bring up an agent](agent-up.md#restore-state-and-seed-the-workspace).

The launcher enforces these deployment-owned settings on every `agent up`:

- Hermes process and local terminal working directory: `/workdir`
- File-tool safe write roots: `/opt/data` and `/workdir`
- Container API: the `agent` user's rootless Podman socket at `/run/podman/podman.sock`
- Compose client: `podman-compose`

Adding `/workdir` as a safe root does not disable Hermes' built-in protected credential and system-path denylist.

## Runtime image contract

The selected runtime image must provide `podman-compose`. `agent up` checks the command before replacing an existing Hermes container and fails if the image does not satisfy the contract.

The repository `Containerfile` builds the supported image from a pinned official Hermes image:

```bash
podman build -t ghcr.io/example/agentctl-hermes:sha-<commit> .
podman run --rm \
  --entrypoint podman-compose \
  ghcr.io/example/agentctl-hermes:sha-<commit> \
  --version
```

Publish an immutable tag, then select that exact tag during `agent init`, in the bundle's `runtime.image`, or with `agent up --runtime-image`.

The image contains a client only. It does not run a nested container daemon. Hermes receives no rootful socket, host-root mount, `--privileged`, or broad host sudo access.

## Compose verification fixture

Copy `tests/fixtures/compose-workspace` into `/workdir` or use it as a model for a project stack. From a Hermes terminal:

```bash
cd /workdir/compose-workspace
podman-compose --project-name agentctl-check up --detach --wait
curl --fail http://host.containers.internal:18080/known.txt
```

The response is:

```text
agentctl-compose-ok
```

The fixture's `${COMPOSE_WORKSPACE_PATH:-.}:/workspace:ro` bind defaults to relative `.` and demonstrates path parity: the Compose client resolves it inside Hermes to `/workdir/compose-workspace`, and the host rootless Podman daemon sees the same host path. `COMPOSE_WORKSPACE_PATH` exists only to support isolated local runtime-image verification.

From the operator machine, the sibling service is reachable privately through MagicDNS:

```bash
curl --fail http://<agent-hostname>:18080/known.txt
```

The managed DigitalOcean firewall has no public inbound rules, so the same port must not be reachable through the Droplet's public IPv4 address.

Clean up from Hermes:

```bash
podman-compose --project-name agentctl-check down --volumes
```

Compose project volumes, including the fixture's `scratch` volume, belong to disposable compute. They are not moved onto the Hermes provider volume automatically.
