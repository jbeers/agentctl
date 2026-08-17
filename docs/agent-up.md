# Bring up an agent

`agent up` creates or reconciles the private DigitalOcean resources described by one explicit V2 bundle:

```bash
agentctl agent doctor --file agents/sample-agent.agent.yml
agentctl agent up --file agents/sample-agent.agent.yml
```

This command can create billable resources. Authenticate `doctl` normally before running it, and ensure the operator machine can resolve and reach the selected Tailscale hostname. Provider credentials, the local age identity, and local Tailscale credentials remain on the operator machine.

The same public overrides accepted by inspection are available per invocation:

```bash
agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --region fra1 \
  --size s-2vcpu-4gb \
  --hostname sample-agent \
  --runtime-image ghcr.io/example/hermes:sha-0123456
```

Omit `--runtime-image` and `runtime.image` to use the public, digest-pinned `ghcr.io/jbeers/agentctl` runtime without a registry credential. The override is for an explicitly selected immutable alternative.

## First bring-up

For a missing agent, `up`:

1. Validates and decrypts the bundle locally.
2. Validates and stages optional state and workspace archives before provider inspection or mutation.
3. Derives the public half of the bundle's generated Ed25519 identity.
4. Creates or reconciles the managed `agentctl-v2` tag and the `agentctl-private` firewall. The firewall has no inbound rules and permits required outbound traffic.
5. Creates or reuses the regional `agent-home-<agent-name>` volume at the exact configured size.
6. Creates an Ubuntu 24.04 Droplet with the generated public key, Tailscale enrollment, the unprivileged `agent` account, and rootless Podman prerequisites.
7. Waits for OpenSSH over the selected Tailscale MagicDNS hostname.
8. Mounts persistent state, restores requested empty targets under `/opt/data` and `/workdir`, and starts the pinned Hermes image.
9. Returns success only after the private Hermes gateway responds and the running image exposes the required Compose client.

The generated SSH identity removes any requirement to select or register a DigitalOcean account SSH key. The Droplet's public IPv4 address is not used for normal access.

## Reconciliation

Running the same command again reuses one exact-name Droplet and volume, reconciles the deny-inbound firewall, reinstalls the V2 runtime behavior, pulls the selected image, and restarts Hermes. It does not create a duplicate Droplet.

Multiple exact-name Droplets or volumes fail safely. A volume in another region, at another size, or attached to another Droplet also fails rather than being selected or modified arbitrarily.

Existing non-empty values in the persistent `.env` remain authoritative on later runs. Bundle initial values fill only required settings that are missing or empty. Launcher-owned networking and container settings are reconciled separately on every `up`.

Hermes starts in `/workdir`, and its canonical local terminal directory is pinned there through a read-only managed configuration layer. File and patch tools may write under `/opt/data` and `/workdir` while Hermes' protected credential-path denylist remains active. The selected runtime image must provide `podman-compose`; after gateway health is ready, `up` verifies that command inside the running container before reporting success. See [Workspace and Compose](compose-workspace.md).

## Restore state and seed the workspace

`up` can restore a validated state archive into fresh `/opt/data`, seed a validated project archive into fresh `/workdir`, or perform both checks and extractions before Hermes starts. Restoration never merges with existing content, and every archive is treated as secret-bearing.

See [Export and restore state archives](archives.md) for the complete format, validation, empty-target, cleanup, and persistence contract.

## Credential boundaries

The Tailscale enrollment key is sent only through first-boot enrollment for a new Droplet. Use a short-lived, ephemeral, pre-approved key. It is not retransmitted when reconciling an existing Droplet.

An optional registry token is streamed through SSH to host-side `podman login --password-stdin`. It is not placed in cloud-init, command arguments, the Hermes environment, or lifecycle output. Hermes API and dashboard credentials seed only persistent Hermes state.

Local cloud-init, SSH identity, runtime-script, secret-payload, and optional state/workspace archive copies use mode `0600` and are removed after success or failure. Remote temporary scripts, payloads, and archive copies remove themselves and are also cleaned up by `agentctl`.

`/opt/data` is retained on the provider volume. `/workdir` remains part of disposable compute; commit and push work that must survive a future `down`.

## Check and access the running agent

After `up` succeeds, `agent status` reports each readiness layer, `agent ssh` opens an interactive root repair session over Tailscale, and `agent open` launches the private Hermes dashboard. See [Check layered agent health](agent-status.md) and [Access a running agent](agent-access.md).
