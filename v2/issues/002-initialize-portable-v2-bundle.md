# Initialize a portable v2 agent bundle

- **Type:** AFK
- **User stories:** 1–4, 9, 11–18

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Let an operator initialize one portable V2 bundle that can later drive inspection and bring-up. Initialization collects only required operator choices, generates agent-scoped credentials, writes readable intent, encrypts the secret subtree with SOPS/age immediately, and validates the result without contacting DigitalOcean to create resources.

Replace the prototype's provider-account SSH-key selection/import flow with a generated per-agent Ed25519 identity. Keep account-wide provider authentication, the operator's age identity, and local Tailscale membership outside the bundle.

## Acceptance criteria

- [x] `agent init` creates a version 2 bundle at an explicit path and refuses to overwrite any existing target.
- [x] The target is mode `0600` from its first publication and is published atomically.
- [x] The resulting file exposes readable agent identity, compute, state, access, and runtime intent.
- [x] Only the dedicated secret subtree is encrypted; SOPS metadata is present and valid.
- [x] Initialization uses the configured age recipient or SOPS creation rule and fails before prompting for secrets when encryption cannot succeed.
- [x] A dedicated Ed25519 keypair is generated for the agent without requiring an existing DigitalOcean SSH key or local identity path.
- [x] The SSH private key is inserted through SOPS standard input and never appears in process arguments, output, or plaintext target content.
- [x] Required Hermes API/dashboard secrets are generated with appropriate entropy and inserted through SOPS standard input.
- [x] User-entered secrets use hidden, confirmed prompts and reject empty values.
- [x] Temporary private-key and bundle files use restrictive permissions and are removed after both success and failure.
- [x] `agent inspect` can inspect the new bundle without revealing secrets.
- [x] `agent doctor` validates decryption, required values, local `doctl`, SOPS, OpenSSH/SCP, `ssh-keygen`, and a supported browser launcher without creating cloud resources.
- [x] Doctor distinguishes missing local prerequisites from invalid bundle content and provider-authentication failures.
- [x] Automated tests assert exclusive creation, partial encryption, generated-key validity, standard-input secret injection, redaction, and failure cleanup.

## Blocked by

- [001 — Inspect a readable v2 agent bundle](001-inspect-readable-v2-bundle.md)
