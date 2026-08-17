# agentctl

**A private, disposable Hermes coding appliance for DigitalOcean.**

`agentctl` turns one explicit, partially encrypted bundle into an Ubuntu VM running Hermes behind Tailscale. It manages one retained Block Storage volume for Hermes state, a disposable project workspace, and rootless sibling containers—without a hosted control plane or public application ingress.

[Install the public alpha](install.md){ .md-button .md-button--primary }
[Create your first agent](first-agent.md){ .md-button }

Run `agentctl docs` to reopen this website from an installed CLI. It uses `xdg-open` on Linux or `open` on macOS and does not require an agent bundle.

!!! warning "Public alpha and billable resources"
    Linux `amd64` and DigitalOcean are the only supported operator/provider path. `up` can create billable compute and storage. `down` deletes compute but deliberately retains the billable state volume. Read [cost and cleanup](persistence.md) before provisioning.

## Supported lifecycle

```text
install → init → inspect → doctor → up → status → open/ssh → optional state export → down → deliberate volume cleanup
```

- **Install:** download an immutable Linux executable and verify its SHA-256 checksum.
- **Initialize:** create a mode-`0600` V2 bundle with readable intent and SOPS-encrypted secrets.
- **Inspect and diagnose:** resolve a redacted plan and check local/provider prerequisites before mutation.
- **Bring up:** create or reconcile one exact-name Droplet, retained volume, private firewall, and Hermes runtime.
- **Operate:** use layered status, a Tailscale-only dashboard, root repair SSH, rootless Compose, and explicit portable state export.
- **Take down:** safely stop Hermes, flush and unmount state, delete the Droplet and `/workdir`, and retain `/opt/data`.
- **Clean up:** separately delete an unwanted detached volume to stop storage billing.

## Product boundary

| Concern | Supported behavior |
| --- | --- |
| Compute | One Ubuntu 24.04 Linux `amd64` DigitalOcean Droplet per explicit bundle |
| Access | OpenSSH and HTTP through operator-managed Tailscale MagicDNS; no public inbound firewall rules |
| Agent | Hermes in the public digest-pinned `ghcr.io/jbeers/agentctl` runtime |
| Containers | Hermes controls the `agent` user's rootless Podman socket and `podman-compose`; no rootful or nested daemon |
| Durable state | `/opt/data` on `agent-home-<agent-name>`, retained after `down` |
| Workspace | `/workdir` on disposable Droplet storage; Git commit/push remains the operator's responsibility |
| Control plane | None—`agentctl` is a local CLI using DigitalOcean, Tailscale, SSH, and private HTTP |

The dashboard uses HTTP inside Tailscale's encrypted network. The Droplet has outbound Internet access, but normal SSH, gateway, dashboard, and Compose access never uses its public IPv4 address.

## Sanitized lifecycle demonstration

Every value below is synthetic; secret prompts and provider identifiers are omitted.

```console
$ agentctl agent init --name tutorial-agent \
    --file ~/.config/agentctl/agents/tutorial-agent.agent.yml \
    --age-recipient age1synthetic-public-recipient
Tailscale enrollment key: [hidden]
Hermes dashboard password: [hidden]
Registry pull token (optional): [left blank]

$ agentctl agent inspect --file ~/.config/agentctl/agents/tutorial-agent.agent.yml
Agent bundle v2
  Agent name: tutorial-agent [bundle]
  Runtime image: ghcr.io/jbeers/agentctl@sha256:… [bundle]
  Volume name: agent-home-tutorial-agent [derived from Agent name]
  Secrets: configured/generated (values are never shown)
  down retains: provider volume mounted at /opt/data
  down discards: Droplet and /workdir

$ agentctl agent doctor --file ~/.config/agentctl/agents/tutorial-agent.agent.yml
$ agentctl agent up --file ~/.config/agentctl/agents/tutorial-agent.agent.yml
$ agentctl agent status --file ~/.config/agentctl/agents/tutorial-agent.agent.yml
$ agentctl agent open --file ~/.config/agentctl/agents/tutorial-agent.agent.yml
$ agentctl agent down --file ~/.config/agentctl/agents/tutorial-agent.agent.yml
```

The full [first-agent walkthrough](first-agent.md) configures a model provider and scoped GitHub access, proves Hermes terminal/file/patch tools and rootless Compose under `/workdir`, and accounts for every tutorial resource.

## Know what survives

`/opt/data` contains Hermes configuration and may contain model-provider keys, GitHub authentication, memory, and sessions. It survives a cold rebuild with the retained volume. It is working durability, **not an independent backup**.

`/workdir`, uncommitted source, sibling containers, and ordinary Compose volumes disappear with the Droplet. Commit and push important work before `down`.

Read [Persistence, billing, and cleanup](persistence.md) and the plain-language [Security model](security.md) before placing real credentials or projects on an agent.

## Current limits

This project is not a generic cloud framework, hosted service, public tunnel, Kubernetes system, repository manager, or automatic backup product. There is no idle shutdown, second provider, automatic state export, guarded CLI purge, or third-party security audit yet.

See [Project status and limitations](project-status.md), [Troubleshooting](troubleshooting.md), and the [public roadmap](https://github.com/jbeers/agentctl/blob/main/v3/README.md).
