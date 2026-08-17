# Security model

`agentctl` creates a private appliance, not a hardened multi-tenant service. It has passed an operator-controlled live exercise but has not received a third-party security audit.

## Trust boundaries

### Operator machine

The operator machine retains the highest-value control credentials:

- DigitalOcean API authentication
- The private age identity used to decrypt bundles
- Local Tailscale membership

These values are never copied into the agent bundle or Hermes. `agentctl` decrypts a selected bundle locally, keeps values in memory, and uses restrictive temporary files only where an external command requires one.

Do not run lifecycle commands on an untrusted workstation. A process with access to the operator account can read decrypted command memory, age identities, `doctl` configuration, and temporary SSH material.

### Encrypted bundle

Readable bundle fields describe intent. Only the `secrets` subtree may contain non-empty secret values, and SOPS must encrypt that subtree. The encrypted values include:

- A dedicated agent SSH private key
- A Tailscale enrollment key
- Optional host-only registry authentication
- Initial Hermes API, dashboard, and signing credentials

The bundle is portable authority over the named appliance. Redacted CLI output does not make its ciphertext safe to publish. Keep it mode `0600`, outside source repositories, and backed up separately from the private age identity.

Use the write-only [credential rotation](credential-rotation.md) command for Tailscale enrollment keys, optional registry tokens, and dashboard passwords. Replacements use hidden confirmation prompts and SOPS standard input; no command reads a decrypted value back to the operator.

### First-boot enrollment

For a new Droplet, the generated SSH public key and Tailscale auth key enter cloud-init. The private SSH key, DigitalOcean token, age identity, model-provider keys, and GitHub credentials do not.

Use a narrowly scoped reusable ephemeral Tailscale key. Reusability supports cold rebuild; ephemeral nodes support cleanup. Revoke the key when no more replacement hosts should enroll.

### VM and network

The DigitalOcean Droplet has a provider public address for outbound Internet connectivity, but the managed firewall has no public inbound rules. Normal access uses:

- OpenSSH over the Tailscale MagicDNS hostname
- Hermes gateway health over the Tailscale IPv4 address
- The dashboard at `http://<tailscale-hostname>:9119`
- Explicit Compose ports through the tailnet

The dashboard uses HTTP at the application layer. Tailscale encrypts transport between tailnet members. Anyone allowed to reach the node by tailnet policy can attempt to connect, so keep ACLs narrow and retain dashboard authentication. Do not expose these ports through a public firewall, load balancer, or reverse proxy.

### Root repair and Hermes

`agent ssh` opens a root shell and therefore grants full authority over the disposable VM and attached state. Use it for diagnosis or reviewed repair—not routine agent work.

Hermes runs as the image's unprivileged user. It receives:

- Read/write `/opt/data` and `/workdir`
- The `agent` host user's rootless Podman socket
- No rootful container socket
- No host-root mount
- No `--privileged` mode or broad host `sudo`

Hermes can create and control sibling containers owned by that rootless Podman user. Those containers can receive files, ports, environment, or mounts explicitly granted by a Compose definition. Review untrusted Compose files before running them.

## Credential placement

| Credential | Normal location | Deliberately absent from |
| --- | --- | --- |
| DigitalOcean token | Operator `doctl` config | Bundle, VM, Hermes |
| Private age identity | Operator SOPS age directory | Bundle, VM, Hermes |
| Tailscale enrollment key | Encrypted bundle; new-host cloud-init during enrollment | Hermes runtime environment |
| Agent SSH private key | Encrypted bundle; temporary operator file during SSH commands | VM and command output |
| Registry token, when configured | Encrypted bundle; streamed to host rootless `podman login` | Cloud-init, Hermes environment, output |
| Hermes model-provider key | Hermes configuration under `/opt/data` | Bundle, cloud-init, `/workdir` |
| GitHub token | Hermes protected environment under `/opt/data`; Git helper configuration also persists there | Bundle, cloud-init, chat, arbitrary terminal environment, sibling containers by default |
| Dashboard password and Hermes keys | Encrypted bundle for initial seeding; retained Hermes `.env` | Lifecycle output |

A credential under `/opt/data` is available to Hermes and survives a cold rebuild. Scope model and GitHub credentials for that authority level. Do not mount `/opt/data` into a sibling service unless the service is intentionally trusted with everything it can read there.

## Host-key policy

A first connection may accept a previously unseen SSH host key. A changed key is refused. `agent ssh` and `status` never erase a mismatch.

When disposable compute was legitimately replaced, rerun `agent up` with the same explicit bundle. Its exact provider-resource reconciliation owns the verified known-host replacement. Do not bypass a mismatch with `StrictHostKeyChecking=no`.

## State and deletion safety

`/opt/data` may contain provider keys, GitHub credentials, conversation history, and other private state. It remains on the DigitalOcean volume after `down`. The volume is not an independent backup and remains billable.

A state [export](archives.md#export-a-ready-agent) contains that same authority and history. `agentctl` transfers it only over private SSH, validates exact bytes, and publishes it locally at mode `0600`, but the archive and even its path remain secret-bearing. Store it separately from the working volume and never attach it to public support material.

`down` blocks Droplet deletion when Hermes cannot stop, writes cannot flush, or the state filesystem cannot unmount. It does not delete the volume. The separate [`agent purge`](purge.md) command requires exact typed identity, absent compute, a unique matching detached volume, repeated provider checks, and exact-ID deletion. It has no user-facing force bypass and does not claim that a backup exists.

`/workdir` and ordinary Compose volumes are deleted with the Droplet. The security boundary does not include automatic Git review, commit, push, or workspace backup.

## Safe output and support

Normal, verbose, and status JSON output omits decrypted values, SOPS ciphertext, private keys and paths, payloads, remote environment files, registry tokens, raw provider objects, public IPv4, endpoint bodies, and archive contents. Provider and remote output is reduced to focused product states rather than relayed verbatim.

Do not publish a real bundle, ciphertext, archive, hostname, public IP address, provider identifier, or unreviewed verbose log. Follow the repository [security policy](https://github.com/jbeers/agentctl/blob/main/SECURITY.md) for private vulnerability reports and [support policy](https://github.com/jbeers/agentctl/blob/main/SUPPORT.md) for redacted operational help.

## Known limits

The supported boundary is DigitalOcean, Ubuntu 24.04, Linux `amd64`, Tailscale private access, Hermes, and rootless Podman. There is no public-ingress mode, idle-shutdown guarantee, automated independent backup, second provider, hosted control plane, or formal security-audit claim. See [Project status and limitations](project-status.md).
