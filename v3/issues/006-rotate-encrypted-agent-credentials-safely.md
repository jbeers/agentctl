# Rotate encrypted agent credentials safely

- **Type:** AFK
- **User stories:** 49–54

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add a write-only credential-rotation workflow for an existing explicit V2 bundle. The operator selects one supported credential, enters and confirms its replacement with terminal echo disabled, and receives an atomically updated mode-`0600` SOPS bundle only after encryption, schema, and local decryption validation succeed.

Keep the interface narrow. Rotation supports the credentials that naturally expire or require user-initiated replacement; it does not restore the old general secret-reading interface or create a generic encrypted-document editor.

## Acceptance criteria

- [ ] Rotation always requires an explicit `--file` bundle and never scans the current directory.
- [ ] Supported selections include Tailscale enrollment key, registry pull token, and Hermes dashboard password.
- [ ] The registry token can be explicitly removed as well as replaced without using an empty prompt ambiguously.
- [ ] Replacement values are entered and confirmed through hidden prompts and never appear in process arguments, normal output, verbose output, errors, or test failures.
- [ ] SOPS receives values through standard input and preserves partial encryption of only the `secrets` subtree.
- [ ] Every unselected public and encrypted bundle value remains unchanged.
- [ ] The workflow validates the existing bundle, SOPS policy, resulting schema, encryption, and local decryption before publication.
- [ ] Publication is atomic, refuses symlink or non-regular targets, preserves mode `0600`, and never leaves a plaintext or partial replacement behind.
- [ ] Cancellation, confirmation mismatch, SOPS failure, malformed ciphertext, invalid Tailscale format, and interrupted publication leave the original bundle intact and remove temporary files.
- [ ] No command for printing or exporting decrypted bundle credentials is added.
- [ ] `inspect` remains fully redacted and `doctor` succeeds with the rotated bundle.
- [ ] User documentation explains when enrollment keys expire, when rotation affects a running host, and why a fresh `up` consumes the new value only during enrollment.

## Blocked by

- [001 — Establish the canonical public agentctl project](001-establish-canonical-public-agentctl-project.md)
