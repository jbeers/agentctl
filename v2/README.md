# Cloud Agent Coder v2 Roadmap

The canonical product contract is [PRD.md](PRD.md). Implementation work is split into local tracer-bullet issue documents under [`issues/`](issues/).

These are intentionally vertical slices: each produces a user-visible, testable path through parsing, configuration, orchestration, security, and documentation where applicable.

## Issue order

| # | Issue | Type | Status | Blocked by |
|---|---|---|---|---|
| 001 | [Inspect a readable v2 agent bundle](issues/001-inspect-readable-v2-bundle.md) | AFK | Complete | None |
| 002 | [Initialize a portable v2 agent bundle](issues/002-initialize-portable-v2-bundle.md) | AFK | Complete | 001 |
| 003 | [Bring up a private v2 agent](issues/003-bring-up-private-v2-agent.md) | AFK | Complete | 001, 002 |
| 004 | [Run Compose from a writable workspace](issues/004-run-compose-from-writable-workdir.md) | AFK | Complete | 003 |
| 005 | [Restore a Hermes state archive during up](issues/005-restore-hermes-state-archive.md) | AFK | Complete | 003 |
| 006 | [Seed a workspace archive during up](issues/006-seed-workspace-archive.md) | AFK | Complete | 005 |
| 007 | [Access a running agent](issues/007-access-running-agent.md) | AFK | Complete | 003 |
| 008 | [Report layered agent health](issues/008-report-layered-agent-health.md) | AFK | Complete | 003 |
| 009 | [Take an agent down safely](issues/009-take-agent-down-safely.md) | AFK | Complete | 003 |
| 010 | [Prove a cold rebuild end to end](issues/010-prove-cold-rebuild.md) | HITL | Pending | 004–009 |

## Type meanings

- **AFK:** Requirements are settled and the issue can be implemented and verified locally without further design input.
- **HITL:** The issue requires operator approval or interaction, such as creating billable cloud resources or validating real network behavior.

## Working rules

- Preserve the existing uncommitted prototype while implementing slices.
- Prefer adapting proven lifecycle code over rewriting it.
- Do not introduce a provider, secret-store, or storage plugin framework until a second implementation exists.
- Each issue must leave its smallest relevant automated regression check.
- Complete an issue by checking its acceptance criteria and updating this roadmap in the same commit.
- Live Droplet creation, volume deletion, firewall changes, and credential rotation require explicit operator approval.
