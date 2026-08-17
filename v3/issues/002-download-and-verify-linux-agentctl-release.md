# Download and verify a Linux agentctl release

- **Type:** HITL
- **User stories:** 9–20

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Deliver the first complete user path from a public release page to a verified native `agentctl` executable. A Linux `amd64` operator must be able to download the binary and checksum, verify the bytes, install it, and identify its version without installing BoxLang, CommandBox, MatchBox, Rust, or the repository development dependencies.

The same release automation must prove the existing behavior with the pinned native toolchain before publishing immutable artifacts.

## Acceptance criteria

- [x] Continuous integration uses explicitly pinned BoxLang, TestBox, YAML, MatchBox, and other build inputs rather than a developer-local compiler path.
- [x] Pull requests and release builds run the complete TestBox suite, generated-Bash syntax checks, whitespace checks, native compilation, and native smoke checks.
- [x] `agentctl --version` reports the application version and source revision without contacting a provider or reading a bundle.
- [x] The first supported artifact is identified explicitly as Linux `amd64`; unsupported operator platforms are not implied.
- [x] A tagged public release publishes an executable with an immutable versioned filename and a SHA-256 checksum.
- [x] The downloaded executable runs `--version`, `--help`, and a redacted fixture inspection without the project development toolchain.
- [x] Release notes identify behavior changes, security-relevant changes, known limitations, and required operator action.
- [x] Installation, upgrade, uninstall, and checksum-verification instructions use direct release artifacts and do not require a curl-pipe-shell installer.
- [x] Uninstall guidance states that removing the local executable does not remove Droplets, volumes, Tailscale nodes, or other cloud resources.
- [x] Existing version 2 bundles remain readable; no bundle migration is introduced by application release versioning.

## Completion evidence

- The maintainer approved publication after the canonical pinned-toolchain CI build passed.
- GitHub release `v0.1.0-alpha.1` contains only `agentctl-0.1.0-alpha.1-linux-amd64` and its SHA-256 checksum.
- The downloaded checksum verifies, and the downloaded executable runs `--version`, `--help`, and redacted V2 fixture inspection in an isolated environment containing no development toolchain.
- `--version` identifies the exact tagged source revision; valid V2 fixtures remain readable without migration.

## Blocked by

None — complete.
