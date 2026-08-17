# Expose layered status as JSON

- **Type:** AFK
- **User stories:** 65–69

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add an explicit JSON mode to the existing read-only layered status command. The machine representation must expose `agentctl` product states rather than raw DigitalOcean, SSH, Podman, or HTTP responses. Human text remains the default, and ready/non-ready exit semantics remain unchanged.

This is the first narrow automation contract needed by a future admin Hermes integration. Do not generalize every lifecycle command or add a daemon in this slice.

## Acceptance criteria

- [ ] Status accepts one documented explicit JSON option without changing default text output.
- [ ] Successful JSON output is one valid document with a schema version, agent identity, overall state, readiness boolean, and ordered dependency layers.
- [ ] Each layer reports a stable state vocabulary and only the minimal safe product detail needed to explain ready, absent, provisioning, unhealthy, not-checked, or indeterminate outcomes.
- [ ] Raw provider objects, public IPv4, command stderr, environment content, credentials, private-key paths, payloads, and endpoint bodies are never included.
- [ ] Ready returns exit `0`; absent, provisioning, unhealthy, provider failure, and invalid local configuration retain their existing nonzero semantics.
- [ ] Expected non-ready states still emit parseable JSON rather than mixing human diagnostics into stdout.
- [ ] Any unavoidable process-level diagnostic is separated from JSON stdout and remains secret-safe.
- [ ] `--verbose` either has a documented safe JSON representation or is rejected clearly with JSON mode; it never corrupts the document.
- [ ] Existing dependency short-circuit behavior, strict host-key behavior, and private-route checks are unchanged.
- [ ] Schema fields and allowed values are documented as a compatibility contract for the current application major version.
- [ ] Tests cover every status boundary, exact JSON parsing, key presence, stable value types, exit codes, stdout/stderr separation, and redaction.
- [ ] A small shell or standard-library consumer example proves that automation does not need to scrape human text.

## Blocked by

- [001 — Establish the canonical public agentctl project](001-establish-canonical-public-agentctl-project.md)
