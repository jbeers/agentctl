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
- [x] Runtime publication builds from the canonical repository for Linux `amd64` and uses the repository's normal package-write credential rather than a maintainer PAT.
- [x] Published release identity is immutable and can be traced to the CLI-compatible source revision.
- [x] The image is smoke-tested for Hermes startup, GitHub CLI, the rootless Podman client, `podman-compose`, `/workdir`, and the configured socket environment before publication succeeds.
- [x] Container publication retains available provenance and SBOM output.
- [x] The package can be pulled anonymously through the normal `agentctl` default.
- [x] The built-in default and user documentation select the supported public release rather than the obsolete prototype image.
- [x] `agent up` verifies the Compose client in the running Hermes container before reporting success.
- [x] An immutable private-image override and optional host-only registry token continue to work without exposing the token to Hermes or lifecycle output.
- [x] Runtime upgrade guidance explains reconciliation, retained `/opt/data`, and disposable `/workdir` behavior.

## Completion evidence

- The maintainer approved and made `ghcr.io/jbeers/agentctl` public after its initial repository-token publication. GitHub requires the first personal-package visibility change through its confirmation UI.
- `runtime-v1` and `sha-ac78d96ecd0fe9b57ca51c930e18a69cc8301abf` resolve to the attested publication from canonical source revision `ac78d96ecd0fe9b57ca51c930e18a69cc8301abf`; no `latest` tag exists.
- Anonymous pulls of the OCI index and exact Linux `amd64` manifest succeeded. The exact default digest started a healthy Hermes gateway and passed GitHub CLI, Podman, `podman-compose`, writable `/workdir`, and socket-environment checks.
- The OCI attestation manifest contains both SPDX SBOM and SLSA provenance predicates.
- The failure-propagating suite passes 79/79 tests, including runtime publication, in-container Compose verification, private-image authentication boundaries, and secret-safe output.

## Blocked by

None — complete.
