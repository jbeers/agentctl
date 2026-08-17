# Use a supported public runtime by default

- **Type:** HITL
- **User stories:** 21–28

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Publish the supported Hermes appliance from the canonical `agentctl` repository and make that public, immutable image the visible built-in default. A new operator following the normal workflow must not need a private GHCR credential, while existing private-image and registry-token behavior remains available as an explicit override.

Publication changes a real public package and therefore requires maintainer review before the workflow is enabled or a package is made public.

## Acceptance criteria

- [x] The maintainer approves public `ghcr.io/jbeers/agentctl`, immutable `runtime-vN` and `sha-<revision>` tags, no `latest` tag, and a digest-pinned built-in default.
- [ ] Runtime publication builds from the canonical repository for Linux `amd64` and uses the repository's normal package-write credential rather than a maintainer PAT.
- [ ] Published release identity is immutable and can be traced to the CLI-compatible source revision.
- [ ] The image is smoke-tested for Hermes startup, GitHub CLI, the rootless Podman client, `podman-compose`, `/workdir`, and the configured socket environment before publication succeeds.
- [ ] Container publication retains available provenance and SBOM output.
- [ ] The package can be pulled anonymously through the normal `agentctl` default.
- [ ] The built-in default and user documentation select the supported public release rather than the obsolete prototype image.
- [ ] `agent up` verifies the Compose client in the running Hermes container before reporting success.
- [ ] An immutable private-image override and optional host-only registry token continue to work without exposing the token to Hermes or lifecycle output.
- [ ] Runtime upgrade guidance explains reconciliation, retained `/opt/data`, and disposable `/workdir` behavior.

## Publication gate

The maintainer approved creation of the public package and the initial `runtime-v1` publication. The digest-pinned default is updated only after anonymous pull and published-image smoke checks pass.

## Blocked by

- [001 — Establish the canonical public agentctl project](001-establish-canonical-public-agentctl-project.md) — complete
