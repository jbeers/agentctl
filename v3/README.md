# agentctl Public Product Roadmap

The completed V2 specification remains the current behavioral contract. [PRD.md](PRD.md) defines the next workstream: publish `agentctl` as an installable public product, launch its documentation website, and add the smallest day-two safety workflows needed for responsible outside use.

This roadmap does **not** introduce a V3 bundle schema. Existing version 2 bundles remain valid.

## Issue order

| # | Issue | Type | Status | Blocked by |
|---|---|---|---|---|
| 001 | [Establish the canonical public agentctl project](issues/001-establish-canonical-public-agentctl-project.md) | HITL | Complete | None |
| 002 | [Download and verify a Linux agentctl release](issues/002-download-and-verify-linux-agentctl-release.md) | HITL | Complete | 001 |
| 003 | [Use a supported public runtime by default](issues/003-use-supported-public-runtime-by-default.md) | HITL | Complete | 001 |
| 004 | [Complete a clean-room first-agent guide](issues/004-complete-clean-room-first-agent-guide.md) | HITL | Pending | 002, 003 |
| 005 | [Launch the docs-first agentctl website](issues/005-launch-docs-first-agentctl-website.md) | AFK | Pending | 004 |
| 006 | [Rotate encrypted agent credentials safely](issues/006-rotate-encrypted-agent-credentials-safely.md) | AFK | Pending | 001 |
| 007 | [Export portable Hermes state](issues/007-export-portable-hermes-state.md) | AFK | Pending | 001 |
| 008 | [Purge retained state safely](issues/008-purge-retained-state-safely.md) | HITL | Pending | 007 |
| 009 | [Expose layered status as JSON](issues/009-expose-layered-status-as-json.md) | AFK | Pending | 001 |
| 010 | [Prove the public alpha end to end](issues/010-prove-public-alpha-end-to-end.md) | HITL | Pending | 002–009 |

## Type meanings

- **AFK:** Requirements are settled and the issue can be implemented and verified locally without further product decisions or live provider mutation.
- **HITL:** The issue requires maintainer decisions, public artifact publication, billable resources, real credentials, or destructive provider approval.

## Working rules

- The V2 PRD and completed acceptance evidence define behavior that this roadmap must preserve.
- Build vertical, independently verifiable slices; do not split work into disconnected release, code, and documentation layers.
- Keep the normal product narrow: Hermes, DigitalOcean, Tailscale, rootless Podman, explicit V2 bundles, and private access.
- Public documentation must describe released behavior, not planned behavior.
- Never publish from a working tree containing operator bundles, credentials, generated artifacts, or local test state.
- Do not weaken secret handling, resource identity checks, archive validation, host-key policy, or destructive-operation safeguards for onboarding convenience.
- Every nontrivial behavior receives the smallest deterministic regression check. Public package changes and final live acceptance remain operator-approved.
- Complete an issue by checking its acceptance criteria and updating this roadmap in the same commit.

## Later, deliberately unticketed

The PRD records longer-term directions—concrete backup storage, a Hermes checkpoint contract, idle shutdown, admin Hermes integration, additional operator platforms, and a second compute provider. They remain unticketed until public-alpha usage supplies a real requirement. This avoids creating a speculative control plane or provider framework before the manual product is distributable and safe.
