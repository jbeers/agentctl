# Establish the canonical public agentctl project

- **Type:** HITL
- **User stories:** 1–8

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Establish the current clean project as the canonical source under the `agentctl` identity. The executable, package metadata, documentation title, support policies, future release naming, and planned runtime package naming must describe one product. The old prototype has no preservation or migration requirement.

The canonical source repository is the public `https://github.com/jbeers/agentctl` project. Public release artifacts remain deferred until their acceptance slices are complete. The maintainer selected Apache License 2.0, `0.1.0-alpha.1`, and support for only the latest public-alpha release.

## Acceptance criteria

- [x] The maintainer approves `agentctl` as the project identity and the current clean V2 implementation as its canonical source.
- [x] The canonical source is published at `https://github.com/jbeers/agentctl` without publishing release artifacts early.
- [x] The maintainer approves Apache License 2.0, `0.1.0-alpha.1`, and support for only the latest public-alpha release.
- [x] The project metadata, executable documentation, support documents, future release naming, and planned runtime package naming consistently use `agentctl`.
- [x] The old prototype has no preservation or migration requirement and is not imported into this project.
- [x] The canonical tracked tree contains no operator bundle, decrypted value, local credential, generated binary, test result, or workstation-only build artifact.
- [x] The approved license and supported-version policy are documented and linked from the repository entry point.
- [x] Security-reporting, contribution, and support documents are present and linked from the repository entry point.
- [x] The security policy distinguishes responsible disclosure from normal bug reports and makes no claim of a third-party audit.
- [x] Public-alpha maturity, DigitalOcean/Hermes/Linux limitations, and the retained-volume billing model are stated plainly.
- [x] The completed V2 specification remains available as the current behavioral baseline, while the V3 roadmap is identified as the next workstream.

## Completion evidence

- The canonical public repository is `https://github.com/jbeers/agentctl`, with issues and private vulnerability reporting enabled.
- Application metadata declares version `0.1.0-alpha.1` and Apache License 2.0.
- Repository history and the tracked publication tree were checked for operator bundles, generated artifacts, and secret patterns before the first push; detected secret-shaped source values are synthetic test fixtures only.
- The complete TestBox suite, native build, native help smoke check, Markdown links, JSON metadata, and whitespace checks pass.

## Blocked by

None — complete.
