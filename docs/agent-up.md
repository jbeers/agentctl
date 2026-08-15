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
2. Derives the public half of the bundle's generated Ed25519 identity.
3. Creates or reconciles the managed `agentctl-v2` tag and the `agentctl-private` firewall. The firewall has no inbound rules and permits required outbound traffic.
4. Creates or reuses the regional `agent-home-<agent-name>` volume at the exact configured size.
5. Creates an Ubuntu 24.04 Droplet with the generated public key, Tailscale enrollment, the unprivileged `agent` account, and rootless Podman prerequisites.
6. Waits for OpenSSH over the selected Tailscale MagicDNS hostname.
7. Mounts persistent state at `/agent-dirs/<agent-name>`, exposes it to Hermes as `/opt/data`, and starts the pinned Hermes image.
8. Returns success only after the private Hermes gateway health endpoint responds.

The generated SSH identity removes any requirement to select or register a DigitalOcean account SSH key. The Droplet's public IPv4 address is not used for normal access.

## Reconciliation

Running the same command again reuses one exact-name Droplet and volume, reconciles the deny-inbound firewall, reinstalls the V2 runtime behavior, pulls the selected image, and restarts Hermes. It does not create a duplicate Droplet.

Multiple exact-name Droplets or volumes fail safely. A volume in another region, at another size, or attached to another Droplet also fails rather than being selected or modified arbitrarily.

The persistent `.env` under Hermes state is seeded only when empty. Existing Hermes settings remain authoritative on later runs. Launcher-owned networking and container settings are reconciled separately on every `up`.

## Credential boundaries

The Tailscale enrollment key is sent only through first-boot enrollment for a new Droplet. Use a short-lived, ephemeral, pre-approved key. It is not retransmitted when reconciling an existing Droplet.

An optional registry token is streamed through SSH to host-side `podman login --password-stdin`. It is not placed in cloud-init, command arguments, the Hermes environment, or lifecycle output. Hermes API and dashboard credentials seed only persistent Hermes state.

Local cloud-init, SSH identity, runtime-script, and secret-payload files use mode `0600` and are removed after success or failure. Remote temporary scripts and payloads remove themselves and are also cleaned up by `agentctl`.

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
