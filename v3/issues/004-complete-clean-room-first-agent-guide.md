# Complete a clean-room first-agent guide

- **Type:** HITL
- **User stories:** 29–43, 46–48

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Create and prove one public, newcomer-oriented journey from an empty supported Linux system to a useful private Hermes agent and complete cost cleanup. The guide must use the downloadable release and public default runtime rather than a source checkout, maintainer workstation, private package, or undocumented credential.

The result is canonical Markdown that can be read in the repository before the documentation website is deployed.

## Acceptance criteria

- [x] One prerequisites page covers supported platform, DigitalOcean account and `doctl` authentication, local Tailscale membership, reusable ephemeral enrollment-key guidance, SOPS, age, OpenSSH, and browser requirements.
- [x] Age identity creation, recipient selection, private-key protection, and SOPS partial-encryption expectations are documented without using a real credential.
- [x] Default Droplet and retained-volume billing behavior is explained before the first mutating command, with a link to current provider pricing rather than a permanently hardcoded estimate.
- [x] The walkthrough covers installation, `init`, redacted `inspect`, `doctor`, `up`, layered `status`, `ssh`, `open`, `down`, and final retained-volume cleanup.
- [x] The first-agent path uses the public runtime without a registry token.
- [x] First-use Hermes model-provider setup is documented sufficiently for the agent to perform a real task.
- [x] Persistent GitHub authentication and credential scoping inside Hermes are documented without placing project credentials in cloud-init or sibling containers.
- [x] A small first task proves Hermes terminal, file, patch, and rootless Compose behavior under `/workdir`.
- [x] The guide repeatedly distinguishes durable `/opt/data`, disposable `/workdir`, Git responsibility, provider-volume durability, and independent backup.
- [x] Security boundaries, HTTP-over-Tailscale behavior, public-firewall behavior, root repair SSH, and known product limitations are linked from the walkthrough.
- [x] Troubleshooting is organized by prerequisite, bundle, provider, storage, Tailscale/SSH, container, gateway, dashboard, and archive layers.
- [x] All commands, screenshots, and recordings use synthetic values and contain no real account identifiers, ciphertext, private paths, or credentials.
- [x] An operator-approved clean-room exercise completes the guide without installing the development toolchain or manually repairing the VM.
- [x] The exercise ends with every test Droplet, retained volume, Tailscale node, known-host entry, bundle, and temporary file accounted for and removed under the approved cleanup plan.

## Completion evidence

- An isolated Ubuntu 24.04 Linux `amd64` operator environment installed the checksum-verified `v0.1.0-alpha.2` executable and normal prerequisites from public artifacts. No source checkout, BoxLang, CommandBox, MatchBox, or Rust toolchain entered the environment.
- A fresh age identity and synthetic-name bundle completed `init`, redacted `inspect`, and read-only `doctor`. The bundle selected the public digest-pinned runtime and intentionally omitted a registry token.
- Initial `up` correctly stopped when the operator's local Tailscale client was offline. Restarting that local prerequisite and rerunning the same released command completed reconciliation; the VM received no manual repair.
- Layered status reached `ready`; private dashboard access, root repair SSH, anonymous runtime use, and deny-inbound behavior passed. A model provider answered a real request.
- Scoped GitHub authentication and Git credential setup completed under retained Hermes state. A repository request coincided with an independently confirmed GitHub major partial outage and was not treated as an appliance failure.
- Hermes used terminal, file-writing, and patch tools under `/workdir`, started a rootless Compose sibling, and returned `agentctl-compose-ok` privately while the public port remained unreachable. The exercise exposed and removed an unsupported `podman-compose --wait` assumption from the guide.
- Compose resources were removed, `down` completed its guarded shutdown, the exact detached 10 GiB tutorial volume was deleted after approved identity checks, and the ephemeral Tailscale node disappeared.
- Final checks found no exact-name Droplet, volume, Tailscale node, known-host entry, bundle, copied provider configuration, temporary age identity, test log, clean-room container, or image. The operator revoked the temporary Tailscale and GitHub credentials.

## Blocked by

None — complete.
