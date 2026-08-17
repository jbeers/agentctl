# Inspect a readable v2 agent bundle

- **Type:** AFK
- **User stories:** 1–10, 14, 15

## Parent

[agentctl V2 PRD](../PRD.md)

## What to build

Add the first complete V2 path: an operator can explicitly select a version 2 agent bundle and inspect the effective, redacted plan without mutating local files, cloud resources, SSH state, or persistent state.

The bundle resolver must accept readable non-secret fields and a partially SOPS-encrypted secret subtree, decrypt only in memory, validate a deliberately small schema, apply visible defaults, derive resource names, and retain the source of each effective value. The inspection output is the first user-facing contract for eliminating hidden configuration.

This slice should reuse the current parser, configuration service, and argv-based command runner where they already provide the required safety. It should not introduce provider or backend interfaces.

## Acceptance criteria

- [x] `agent inspect` accepts an explicit agent bundle path and performs no cloud or remote command.
- [x] A version 2 plaintext fixture with no secrets can be parsed for structural tests.
- [x] A partially SOPS-encrypted fixture is decrypted directly from command output and is never written as plaintext.
- [x] Non-secret fields remain readable in the encrypted source file.
- [x] Unknown keys, wrong value types, unsupported versions, and missing required identity fields fail with focused messages.
- [x] Empty optional values do not create hidden overrides.
- [x] Inspection shows the agent name, compute provider and size, region, hostname, runtime image, access method, working-state strategy, derived Droplet and volume names, and what `down` retains.
- [x] Every effective non-secret value is labeled as coming from the bundle, a CLI argument, or a built-in default.
- [x] Secret fields are represented only as configured, missing, or generated; values and ciphertext are never printed.
- [x] Archive options are shown as per-invocation inputs rather than persistent bundle configuration.
- [x] The canonical workflow requires explicit bundle selection; V2 inspection does not scan the current directory for an arbitrary agent file.
- [x] Errors and verbose diagnostics do not include decrypted content or private-key material.
- [x] Unit tests cover plaintext, encrypted, malformed, unknown-key, missing-tool, and redaction behavior.
- [x] Existing V1 behavior remains untouched by this slice unless a clear unsupported-version message is needed at the V2 entry point.

## Blocked by

None — can start immediately.
