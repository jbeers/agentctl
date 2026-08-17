# Prerequisites

Complete this page before creating an agent. The checks through `agent doctor` are local or read-only; `agent up` is the first command that can create billable resources.

## Supported operator system

The released operator executable supports only:

- Linux on `amd64`/`x86_64`
- A normal user account with permission to install a local executable
- Network access to GitHub, DigitalOcean, Tailscale, and the selected model provider

Confirm the platform:

```bash
uname -s    # Linux
uname -m    # x86_64
```

The managed VM is Ubuntu 24.04 on Linux `amd64`. macOS, Windows, WSL, Linux `arm64`, and other cloud providers are not currently supported operator paths.

## Understand the cost first

The built-in plan creates these DigitalOcean resources when they do not already exist:

- One `s-4vcpu-8gb` Droplet in `nyc3`
- One 10 GiB Block Storage volume named `agent-home-<agent-name>`
- One shared deny-inbound firewall and one shared managed tag

Check current [Droplet pricing](https://www.digitalocean.com/pricing/droplets) and [Block Storage pricing](https://www.digitalocean.com/pricing/volumes) before continuing. Prices are intentionally not copied here because provider prices change.

`agent down` deletes the Droplet and its disposable `/workdir`, but deliberately retains the volume and durable `/opt/data`. The volume continues billing until you separately delete it. Removing the executable or bundle deletes no cloud resource. See [Persistence, billing, and cleanup](persistence.md).

## DigitalOcean account and doctl

1. Create a DigitalOcean account with billing enabled.
2. Install [`doctl`](https://docs.digitalocean.com/reference/doctl/how-to/install/).
3. Create a DigitalOcean API token in the control panel. It must allow account reads and the Droplet, volume, firewall, and tag reads/writes used by `up`, `status`, and `down`. Limit the token to this work when DigitalOcean's available scopes permit it.
4. Authenticate through `doctl`'s interactive prompt rather than putting the token in a command argument:

```bash
doctl auth init --context agentctl
doctl auth switch --context agentctl
doctl account get
```

Keep `~/.config/doctl/config.yaml` private. The token remains on the operator machine; it is not copied into the agent bundle, cloud-init, VM, or Hermes container.

## Tailscale membership and enrollment key

The operator machine must already be connected to the intended tailnet, with MagicDNS enabled:

```bash
tailscale status
tailscale ip -4
```

The tailnet policy must allow the operator to reach the new node on:

- TCP 22 for OpenSSH
- TCP 8642 for Hermes gateway health
- TCP 9119 for the Hermes dashboard
- Any explicitly published Compose service port used by the operator

Create an auth key in the [Tailscale keys settings](https://login.tailscale.com/admin/settings/keys). Follow the upstream [auth-key guidance](https://tailscale.com/kb/1085/auth-keys) and select:

- **Reusable:** required if the same encrypted bundle may enroll replacement Droplets later.
- **Ephemeral:** appropriate because the Tailscale node belongs to disposable compute.
- **Pre-approved:** enable only when device approval is active and your tailnet policy permits it.
- **Tags:** use a narrowly scoped tag only when your ACL policy and `tagOwners` are already configured for it.
- **Expiration:** long enough for the planned bring-up and any intended cold rebuild; revoke it when no further enrollment is needed.

The key enters the encrypted bundle through a hidden `agent init` prompt. For a new Droplet, `agentctl` sends it in first-boot cloud-init so that the host can join the tailnet. It is not sent to Hermes or retransmitted while reconciling an existing Droplet.

Do not use an OAuth client secret, API token, or one-off key where a reusable auth key is required. Never paste the key into documentation, shell arguments, chat, or a plaintext YAML file.

## age identity and SOPS

Install [`age`](https://github.com/FiloSottile/age#installation) and [`SOPS`](https://getsops.io/docs/#download). Create the default SOPS age directory and one private identity if you do not already have one:

```bash
age_key_file="$HOME/.config/sops/age/keys.txt"
install -d -m 0700 "$(dirname "$age_key_file")"
if test -e "$age_key_file"; then
  printf 'Refusing to replace existing age identity: %s\n' "$age_key_file" >&2
else
  (umask 077 && age-keygen -o "$age_key_file")
fi
chmod 0600 "$age_key_file"
age-keygen -y "$age_key_file"
```

The final command prints the public recipient beginning with `age1`; it does not print the private identity. Select a recipient whose private identity is available on every operator machine that must inspect or operate the bundle.

Protect and independently back up `keys.txt`. Anyone with that private identity and the encrypted bundle can recover all bundle secrets. Losing every copy makes the bundle undecryptable. Do not commit the identity, place it beside the bundle, or send it to the VM.

`agent init --age-recipient <public-recipient>` is the simplest path. If you instead rely on a SOPS creation rule, it must encrypt only the `secrets` subtree:

```yaml
creation_rules:
  - path_regex: .*\.agent\.yml$
    encrypted_regex: ^secrets$
    age: age1synthetic-recipient-used-only-in-documentation
```

Public intent such as agent name, region, size, hostname, and runtime image remains readable by design. Non-empty values below `secrets` must be encrypted. Treat the whole bundle—including its ciphertext and SOPS metadata—as private even though inspection output is redacted.

## OpenSSH, browser, and local commands

Install these normal operator tools:

- `ssh`, `scp`, and `ssh-keygen` from OpenSSH
- `xdg-open` and a browser capable of reaching tailnet HTTP addresses
- `curl` and `sha256sum` for release installation
- `python3` when exporting or restoring state, or when seeding a workspace archive

Check the commands without printing credentials:

```bash
for command in doctl sops age-keygen ssh scp ssh-keygen xdg-open curl sha256sum; do
  command -v "$command" >/dev/null || printf 'missing: %s\n' "$command"
done
```

The browser opens `http://<tailscale-hostname>:9119`. Application traffic is plain HTTP inside Tailscale's encrypted network; the DigitalOcean firewall exposes no public inbound route. Do not publish the dashboard through a public proxy.

## Ready to continue

You should now have:

- A supported Linux `amd64` operator system
- An authenticated `doctl` context
- Active membership in the intended tailnet and a reusable ephemeral enrollment key
- SOPS, an age recipient, and a protected private age identity
- OpenSSH and a working browser launcher
- An explicit understanding of Droplet and retained-volume billing

Continue with [Install agentctl](install.md), then [Create your first agent](first-agent.md).
