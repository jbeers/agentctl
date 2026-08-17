# Complete a clean-room first-agent guide

- **Type:** HITL
- **User stories:** 29–43, 46–48

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Create and prove one public, newcomer-oriented journey from an empty supported Linux system to a useful private Hermes agent and complete cost cleanup. The guide must use the downloadable release and public default runtime rather than a source checkout, maintainer workstation, private package, or undocumented credential.

The result is canonical Markdown that can be read in the repository before the documentation website is deployed.

## Acceptance criteria

- [ ] One prerequisites page covers supported platform, DigitalOcean account and `doctl` authentication, local Tailscale membership, reusable ephemeral enrollment-key guidance, SOPS, age, OpenSSH, and browser requirements.
- [ ] Age identity creation, recipient selection, private-key protection, and SOPS partial-encryption expectations are documented without using a real credential.
- [ ] Default Droplet and retained-volume billing behavior is explained before the first mutating command, with a link to current provider pricing rather than a permanently hardcoded estimate.
- [ ] The walkthrough covers installation, `init`, redacted `inspect`, `doctor`, `up`, layered `status`, `ssh`, `open`, `down`, and final retained-volume cleanup.
- [ ] The first-agent path uses the public runtime without a registry token.
- [ ] First-use Hermes model-provider setup is documented sufficiently for the agent to perform a real task.
- [ ] Persistent GitHub authentication and credential scoping inside Hermes are documented without placing project credentials in cloud-init or sibling containers.
- [ ] A small first task proves Hermes terminal, file, patch, and rootless Compose behavior under `/workdir`.
- [ ] The guide repeatedly distinguishes durable `/opt/data`, disposable `/workdir`, Git responsibility, provider-volume durability, and independent backup.
- [ ] Security boundaries, HTTP-over-Tailscale behavior, public-firewall behavior, root repair SSH, and known product limitations are linked from the walkthrough.
- [ ] Troubleshooting is organized by prerequisite, bundle, provider, storage, Tailscale/SSH, container, gateway, dashboard, and archive layers.
- [ ] All commands, screenshots, and recordings use synthetic values and contain no real account identifiers, ciphertext, private paths, or credentials.
- [ ] An operator-approved clean-room exercise completes the guide without installing the development toolchain or manually repairing the VM.
- [ ] The exercise ends with every test Droplet, retained volume, Tailscale node, known-host entry, bundle, and temporary file accounted for and removed under the approved cleanup plan.

## Blocked by

- [002 — Download and verify a Linux agentctl release](002-download-and-verify-linux-agentctl-release.md)
- [003 — Use a supported public runtime by default](003-use-supported-public-runtime-by-default.md)
