# Bring up an agent

`agent up` creates or reconciles the private DigitalOcean resources described by one explicit V2 bundle:

```bash
./bin/agentctl agent doctor --file agents/sample-agent.agent.yml
./bin/agentctl agent up --file agents/sample-agent.agent.yml
```

This command can create billable resources. Authenticate `doctl` normally before running it, and ensure the operator machine can resolve and reach the selected Tailscale hostname. Provider credentials, the local age identity, and local Tailscale credentials remain on the operator machine.

The same public overrides accepted by inspection are available per invocation:

```bash
./bin/agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --region fra1 \
  --size s-2vcpu-4gb \
  --hostname sample-agent \
  --runtime-image ghcr.io/example/hermes:sha-0123456
```

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
9. Returns success only after the private Hermes gateway health endpoint responds.

The generated SSH identity removes any requirement to select or register a DigitalOcean account SSH key. The Droplet's public IPv4 address is not used for normal access.

## Reconciliation

Running the same command again reuses one exact-name Droplet and volume, reconciles the deny-inbound firewall, reinstalls the V2 runtime behavior, pulls the selected image, and restarts Hermes. It does not create a duplicate Droplet.

Multiple exact-name Droplets or volumes fail safely. A volume in another region, at another size, or attached to another Droplet also fails rather than being selected or modified arbitrarily.

Existing non-empty values in the persistent `.env` remain authoritative on later runs. Bundle initial values fill only required settings that are missing or empty. Launcher-owned networking and container settings are reconciled separately on every `up`.

Hermes starts in `/workdir`, and its canonical local terminal directory is pinned there through a read-only managed configuration layer. File and patch tools may write under `/opt/data` and `/workdir` while Hermes' protected credential-path denylist remains active. The selected runtime image must provide `podman-compose`; `up` verifies that contract before replacing the running Hermes container. See [Workspace and Compose](compose-workspace.md).

## Restore state and seed the workspace

Supply local archives only when their destinations are fresh or empty:

```bash
# Restore durable Hermes state into /opt/data
./bin/agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --state-archive recovery/hermes-state.tar

# Seed disposable project files into /workdir
./bin/agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --workspace-archive recovery/workspace.tar

# Restore both in one operation
./bin/agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --state-archive recovery/hermes-state.tar \
  --workspace-archive recovery/workspace.tar
```

Relative paths resolve from the directory where `agentctl` is invoked. State entries are placed directly under `/opt/data`, and workspace entries directly under `/workdir`; neither archive requires a wrapper directory. A fresh ext4 state filesystem's empty `lost+found` directory is ignored, but archives may not contain or target it.

Before inspecting or changing provider resources, `up` copies each source into a separate mode-`0600` local temporary file and validates the exact copied bytes with the same format rules. Validation rejects malformed archives, absolute or parent-traversing paths, duplicate destinations, escaping links, devices, FIFOs, sockets, and other special entries. Safe regular files, directories, symbolic links, and hard links are supported. Executable modes remain usable; unsafe ownership and permission bits are discarded.

Validated copies are transferred over SCP as mode-`0600` temporary files and revalidated on the host. All requested destinations are checked before extraction. A non-empty target fails rather than merging, skipping, or overwriting files. Extraction and ownership normalization finish before `.env` seeding, Compose inspection, or Hermes startup. If either requested extraction fails, Hermes remains stopped and content extracted by the same operation is removed from both targets.

A restored non-empty state `.env` keeps its existing values; only missing or empty required initial settings are added from the bundle. Workspace seeding does not inspect or change Git remotes, branches, credentials, commits, or dirty state. `/workdir` remains disposable after seeding, so commit and push work that must survive `down`.

All temporary copies are removed after success or failure. Normal output reports stages and workspace disposability, never archive paths or entries. With `--verbose`, success may additionally report each source path, byte size, and SHA-256 digest. Treat both sources as secret-bearing data. Archive use requires local `python3`; Ubuntu host enrollment includes it.

Restoration never merges into an existing target. To restore retained state, use a different fresh agent/volume or deliberately remove existing state through an out-of-band recovery procedure; `agentctl` has no destructive purge command.

## Credential boundaries

The Tailscale enrollment key is sent only through first-boot enrollment for a new Droplet. Use a short-lived, ephemeral, pre-approved key. It is not retransmitted when reconciling an existing Droplet.

An optional registry token is streamed through SSH to host-side `podman login --password-stdin`. It is not placed in cloud-init, command arguments, the Hermes environment, or lifecycle output. Hermes API and dashboard credentials seed only persistent Hermes state.

Local cloud-init, SSH identity, runtime-script, secret-payload, and optional state/workspace archive copies use mode `0600` and are removed after success or failure. Remote temporary scripts, payloads, and archive copies remove themselves and are also cleaned up by `agentctl`.

`/opt/data` is retained on the provider volume. `/workdir` remains part of disposable compute; commit and push work that must survive a future `down`.

## Open the Hermes dashboard

After `up` succeeds, launch the private dashboard in the system browser:

```bash
./bin/agentctl agent open --file agents/sample-agent.agent.yml
```

`open` uses the bundle's effective Tailscale hostname and port `9119`. It invokes `xdg-open` on Linux or `open` on macOS and does not contact DigitalOcean. A per-command hostname override is useful while resolving a temporary MagicDNS collision:

```bash
./bin/agentctl agent open \
  --file agents/sample-agent.agent.yml \
  --hostname sample-agent-1
```

Dashboard credentials are not placed in the URL or browser command; sign in through the Hermes UI.
