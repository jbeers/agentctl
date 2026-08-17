# Expose layered status as JSON

- **Type:** AFK
- **User stories:** 65–69

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add an explicit JSON mode to the existing read-only layered status command. The machine representation must expose `agentctl` product states rather than raw DigitalOcean, SSH, Podman, or HTTP responses. Human text remains the default, and ready/non-ready exit semantics remain unchanged.

This is the first narrow automation contract needed by a future admin Hermes integration. Do not generalize every lifecycle command or add a daemon in this slice.

## Acceptance criteria

- [x] Status accepts one documented explicit JSON option without changing default text output.
- [x] Successful JSON output is one valid document with a schema version, agent identity, overall state, readiness boolean, and ordered dependency layers.
- [x] Each layer reports a stable state vocabulary and only the minimal safe product detail needed to explain ready, absent, provisioning, unhealthy, not-checked, or indeterminate outcomes.
- [x] Raw provider objects, public IPv4, command stderr, environment content, credentials, private-key paths, payloads, and endpoint bodies are never included.
- [x] Ready returns exit `0`; absent, provisioning, unhealthy, provider failure, and invalid local configuration retain their existing nonzero semantics.
- [x] Expected non-ready states still emit parseable JSON rather than mixing human diagnostics into stdout.
- [x] Any unavoidable process-level diagnostic is separated from JSON stdout and remains secret-safe.
- [x] `--verbose` either has a documented safe JSON representation or is rejected clearly with JSON mode; it never corrupts the document.
- [x] Existing dependency short-circuit behavior, strict host-key behavior, and private-route checks are unchanged.
- [x] Schema fields and allowed values are documented as a compatibility contract for the current application major version.
- [x] Tests cover every status boundary, exact JSON parsing, key presence, stable value types, exit codes, stdout/stderr separation, and redaction.
- [x] A small shell or standard-library consumer example proves that automation does not need to scrape human text.

## Completion evidence

- `agent status --file <bundle> --json` is explicit. Text formatting remains the default, while `--verbose --json` is rejected before checks with a focused parser error.
- Schema version 1 emits exactly typed top-level identity/state/readiness fields and seven ordered dependency layers: configuration, compute, volume, access, container, gateway, and dashboard.
- Every layer uses only `ready`, `absent`, `provisioning`, `unhealthy`, `not_checked`, or `indeterminate`, plus a documented stable safe detail code. Provider IDs and raw command/endpoint data remain only inside the check implementation and never enter JSON.
- Expected non-ready results emit one JSON document on stdout and exit `1` without human text. Provider and invalid-local failures emit an indeterminate document on stdout and a separate focused diagnostic on stderr.
- Existing status checks, short-circuit order, strict `StrictHostKeyChecking=yes`, temporary identity cleanup, private Tailscale routes, and ready-only exit `0` behavior are unchanged.
- The suite passes 102/102 checks. JSON coverage parses ready, absent, provisioning, every unhealthy layer, host-key/Tailscale/local-access failures, provider indeterminacy, invalid local configuration, exact keys/types/order, allowed vocabularies, exit codes, and redaction.
- Native fake-provider acceptance parsed absent, provider-failure, and invalid-bundle stdout as JSON; verified stderr separation and secret sanitization; rejected the verbose combination without stdout; and confirmed unchanged default human output.
- [Layered agent health](../../docs/agent-status.md#json-automation-contract) documents the schema compatibility contract, every allowed state/detail, exit and stream semantics, and a Bash/Python standard-library consumer that does not scrape text.

## Blocked by

None — complete.
