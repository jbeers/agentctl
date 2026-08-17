# Establish the canonical public agentctl project

- **Type:** HITL
- **User stories:** 1–8

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Establish one clean, public home for the project under the `agentctl` identity. The repository, executable, release naming, documentation title, support channels, and normal runtime package naming must describe one product. Preserve the old Cloud Agent Coder prototype as history without importing its local working files into the release source.

This slice includes the human decisions that cannot be inferred safely: public repository location and visibility, open-source license, initial application version, and supported-version policy.

## Acceptance criteria

- [ ] The maintainer approves the canonical repository location, public visibility, license, and first public-alpha version.
- [ ] The current clean V2 implementation is the canonical source for the new repository.
- [ ] The project, repository metadata, executable documentation, and release naming consistently use `agentctl`.
- [ ] The old prototype is preserved through an explicit archive, tag, branch, or archived repository without merging its uncommitted working tree into the new source.
- [ ] The published tree contains no operator bundle, decrypted value, local credential, generated binary, test result, or workstation-only build artifact.
- [ ] License, security-reporting, contribution, support, and supported-version documents are present and linked from the repository entry point.
- [ ] The security policy distinguishes responsible disclosure from normal bug reports and makes no claim of a third-party audit.
- [ ] Public-alpha maturity, DigitalOcean/Hermes/Linux limitations, and the retained-volume billing model are stated plainly.
- [ ] The completed V2 specification remains available as the current behavioral baseline, while the V3 roadmap is identified as the next workstream.

## Blocked by

None — can start immediately.
