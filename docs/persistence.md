# Persistence, billing, and cleanup

`agentctl` deliberately separates durable Hermes state from disposable compute. Understand that boundary before storing credentials or source code.

## Storage map

| Location or resource | Lifetime | Typical contents | Backup responsibility |
| --- | --- | --- | --- |
| Encrypted `*.agent.yml` bundle | Operator-managed | Appliance identity, encrypted SSH/Tailscale/Hermes bootstrap credentials | Operator |
| Operator age identity | Operator-managed | Private key able to decrypt the bundle | Operator; store separately from the bundle |
| DigitalOcean volume mounted at `/opt/data` | Retained across `down` and cold rebuild | Hermes configuration, memory, sessions, model credentials, and persistent GitHub CLI configuration | Operator; provider durability is not an independent backup |
| Droplet `/workdir` | Deleted by `down` and cold rebuild | Project checkouts, uncommitted edits, build output, and Compose bind-mounted files | Hermes and operator through Git commit/push or another explicit copy |
| Rootless Compose containers and ordinary named volumes | Droplet-local | Sibling service state | Disposable unless the project deliberately stores data elsewhere |
| Local SSH known-host entry | Disposable-host identity | Host-key trust for the current Droplet | Removed by successful `down`; reconciled by verified `up` after a host replacement |

`/opt/data` is mounted into Hermes. `/workdir` is a separate directory on the Droplet and is the managed Hermes working directory. Putting a file in `/workdir` does not make it durable.

## Lifecycle effects

| Operation | Droplet | `/workdir` | `/opt/data` volume |
| --- | --- | --- | --- |
| First `up` | Created | Created empty or seeded from a workspace archive | Created empty or restored from a state archive |
| Repeated `up` | Reused and reconciled | Kept on the same Droplet | Reused |
| Runtime image change plus `up` | Reused | Kept on the same Droplet | Reused |
| `down` | Deleted | Deleted | Unmounted and retained |
| Later `up` with the same bundle | Recreated | New and empty unless seeded | Reattached with prior Hermes state |
| Provider volume deletion | Independent | Already disposable | Permanently deleted; irreversible |

`agentctl` does not inspect Git status before `down`. Commit and push every change that must survive. A clean provider volume does not protect unpushed `/workdir` content.

## Credentials

Hermes model-provider configuration, scoped GitHub token, and Git credential configuration are stored under `/opt/data`, so they survive a cold rebuild with the same retained volume. They are available to Hermes and should use the least authority needed for that agent.

Do not put project tokens in:

- Cloud-init
- The readable portion of the agent bundle
- Chat prompts or command arguments
- Project files under `/workdir`
- Compose environment files or sibling-container mounts

A sibling container does not receive `/opt/data`, the GitHub configuration, or another credential unless a Compose file explicitly mounts or passes it.

## Billing

`up` may create both a billable Droplet and a billable Block Storage volume. Check current [DigitalOcean Droplet pricing](https://www.digitalocean.com/pricing/droplets) and [Block Storage pricing](https://www.digitalocean.com/pricing/volumes).

`down` ends the managed Droplet but intentionally retains `agent-home-<agent-name>`. Storage charges continue. Firewalls and tags are shared management resources and are not the retained working data.

Complete cleanup requires a separate, deliberate [`agent purge`](purge.md) after `down`. Purge repeats exact name, region, size, attachment, provider-ID, and compute-absence checks around typed agent-name confirmation. Never infer that deleting the local executable or bundle cleaned up the account.

## Backups

A retained provider volume is working durability, not an independent backup. A provider/account failure, accidental deletion, or corrupted filesystem can still destroy it.

`agentctl agent export` creates a validated, portable mode-`0600` archive of `/opt/data` while a ready agent is running. It is a deliberate point-in-time copy, not an automatic backup schedule or provider snapshot. Treat every state archive as secret-bearing because it may contain model credentials, GitHub authentication, Hermes configuration, and conversation history. See [Export and restore state archives](archives.md).

Workspace archives seed only a fresh `/workdir`; they do not change its disposable lifetime. Git remains the normal persistence path for projects.
