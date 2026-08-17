# agentctl

`agentctl` provisions private, disposable Hermes coding agents on DigitalOcean from one explicit SOPS-encrypted bundle.

> **Public alpha:** Linux `amd64`, DigitalOcean, Tailscale private access, Hermes, and rootless Podman are the supported boundary. There is no hosted service or public application ingress.

## Get started

- [Documentation website](https://jbeers.github.io/agentctl/)
- [Prerequisites and cost model](https://jbeers.github.io/agentctl/prerequisites/)
- [Download and verify the Linux release](https://jbeers.github.io/agentctl/install/)
- [Create a first agent and clean it up](https://jbeers.github.io/agentctl/first-agent/)
- [Security model](https://jbeers.github.io/agentctl/security/)

```bash
agentctl agent init
agentctl agent inspect --file agents/sample-agent.agent.yml
agentctl agent doctor --file agents/sample-agent.agent.yml
agentctl agent up --file agents/sample-agent.agent.yml
agentctl agent status --file agents/sample-agent.agent.yml
agentctl agent open --file agents/sample-agent.agent.yml
agentctl agent down --file agents/sample-agent.agent.yml
```

`up` can create billable compute and storage. `down` deletes the Droplet and disposable `/workdir`, but intentionally retains the billable volume containing `/opt/data`. That volume is working state, not an independent backup.

## Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for the pinned development workflow and local checks. The completed [V2 lifecycle](v2/README.md) remains the behavioral baseline; [V3](v3/README.md) tracks public-product work.

## Project policies

- [Apache License 2.0](LICENSE)
- [Security policy](SECURITY.md)
- [Support](SUPPORT.md)
- [Project status and limitations](docs/project-status.md)
