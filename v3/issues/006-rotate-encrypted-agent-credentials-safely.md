# Rotate encrypted agent credentials safely

- **Type:** AFK
- **User stories:** 49–54

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add a write-only credential-rotation workflow for an existing explicit V2 bundle. The operator selects one supported credential, enters and confirms its replacement with terminal echo disabled, and receives an atomically updated mode-`0600` SOPS bundle only after encryption, schema, and local decryption validation succeed.

Keep the interface narrow. Rotation supports the credentials that naturally expire or require user-initiated replacement; it does not restore the old general secret-reading interface or create a generic encrypted-document editor.

## Acceptance criteria

- [x] Rotation always requires an explicit `--file` bundle and never scans the current directory.
- [x] Supported selections include Tailscale enrollment key, registry pull token, and Hermes dashboard password.
- [x] The registry token can be explicitly removed as well as replaced without using an empty prompt ambiguously.
- [x] Replacement values are entered and confirmed through hidden prompts and never appear in process arguments, normal output, verbose output, errors, or test failures.
- [x] SOPS receives values through standard input and preserves partial encryption of only the `secrets` subtree.
- [x] Every unselected public and encrypted bundle value remains unchanged.
- [x] The workflow validates the existing bundle, SOPS policy, resulting schema, encryption, and local decryption before publication.
- [x] Publication is atomic, refuses symlink or non-regular targets, preserves mode `0600`, and never leaves a plaintext or partial replacement behind.
- [x] Cancellation, confirmation mismatch, SOPS failure, malformed ciphertext, invalid Tailscale format, and interrupted publication leave the original bundle intact and remove temporary files.
- [x] No command for printing or exporting decrypted bundle credentials is added.
- [x] `inspect` remains fully redacted and `doctor` succeeds with the rotated bundle.
- [x] User documentation explains when enrollment keys expire, when rotation affects a running host, and why a fresh `up` consumes the new value only during enrollment.

## Completion evidence

- `agent rotate --file <bundle> --credential <name>` accepts only `tailscale-auth-key`, `registry-token`, and `dashboard-password`; only `registry-token` permits the explicit non-prompting `--remove` branch.
- The existing hidden, confirmed terminal prompt is completed before rotation starts. Ctrl-C and confirmation mismatch therefore create no temporary bundle, while SOPS receives the replacement only through `set --value-stdin`.
- `RotateService` rejects symlink and non-regular targets, validates the existing encrypted bundle, stages ciphertext in the target directory at mode `0600`, checks the selected and every unselected value after local decryption, detects concurrent changes, and publishes with a same-directory atomic rename.
- The deterministic suite passes 86/86 checks. Rotation coverage includes all selections, explicit removal, exact preservation, redacted inspection, healthy doctor results, invalid input, SOPS and ciphertext failures, unselected-value changes, failed publication, file types, mode, and temporary-file cleanup.
- A native build passed a real SOPS/age exercise with a disposable synthetic identity and bundle. Hidden replacement and mismatch input never appeared in captured terminal output; the original remained byte-identical while confirmation was incomplete; unselected public and secret hashes stayed unchanged; removal decrypted to empty; the final file remained mode `0600`; and no rotation temporary file remained.
- A separate native Ctrl-C exercise exited safely with the original bundle hash unchanged and no temporary file. No provider, Tailscale, VM, or running Hermes resource was contacted.
- [Rotate encrypted bundle credentials](../../docs/credential-rotation.md) documents expiry, cold-rebuild enrollment, running-host effects, registry removal, validation, redaction, and atomic publication.

## Blocked by

None — complete.
