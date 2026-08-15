# Bring up a private v2 agent

- **Type:** AFK
- **User stories:** 15–28, 39

## Parent

[Cloud Agent Coder v2 PRD](../PRD.md)

## What to build

Implement the core V2 tracer bullet: given one valid bundle and standard operator trust roots, `agent up` creates or reconciles a private DigitalOcean VM and returns success only after Hermes is healthy.

Reuse the prototype's proven volume, firewall, cloud-init, SSH readiness, remote-script, registry-login, and Hermes health logic. Reshape the flow around the V2 bundle, generated agent identity, explicit provider-volume state strategy, and two clear phases: host enrollment followed by runtime reconciliation.

This slice establishes the normal path but does not yet add archive restoration, Compose verification, rich status, or teardown changes covered by later issues.

## Acceptance criteria

- [x] `agent up` requires an explicitly selected valid V2 bundle.
- [x] Provider authentication uses the normal local DigitalOcean credential mechanism and is never copied to the VM or Hermes.
- [x] The public half of the generated agent SSH identity is derived safely and installed during host enrollment without requiring operator selection of a pre-existing account key.
- [x] Host enrollment installs the supported Ubuntu substrate, SSH access, Tailscale, the unprivileged `agent` user, and rootless Podman without accepting an arbitrary user root script.
- [x] The short-lived Tailscale credential is present only in the enrollment path and is rejected when malformed.
- [x] A deny-inbound, allow-required-outbound DigitalOcean firewall is created or reconciled for the managed tag.
- [x] The configured provider-volume working-state strategy creates or reuses one correctly sized regional volume for the exact agent identity.
- [x] A missing exact-name Droplet is created with the selected immutable runtime settings; an existing exact-name Droplet is reconciled instead of duplicated.
- [x] Multiple exact-name Droplets or conflicting volumes fail rather than being selected arbitrarily.
- [x] Runtime reconciliation mounts state at the host state path, installs the versioned bootstrap behavior, and starts Hermes under the rootless `agent` runtime.
- [x] A private registry token is streamed to host Podman login and is absent from cloud-init, SSH arguments, Hermes environment, and logs.
- [x] Initial Hermes values seed an empty state directory but do not replace a non-empty persistent `.env`.
- [x] Launcher-owned settings are reconciled separately from seed-once Hermes values.
- [x] Temporary cloud-init, SSH identity, scripts, and payloads are mode `0600` where applicable and removed on every exit path.
- [x] `up` succeeds only after SSH/Tailscale readiness and the Hermes gateway health endpoint succeed.
- [x] Re-running `up` with the same bundle safely reuses the Droplet and volume while reinstalling/reconciling the runtime.
- [x] Lifecycle output identifies stages and resources but never emits decrypted values.
- [x] Hardcoded Telegram readiness behavior is not part of the V2 bring-up contract.
- [x] Fake-runner tests cover first creation, existing-agent reconciliation, conflicting resources, readiness retries, cleanup after failure, and absence of secrets from argv/output.
- [x] Generated remote Bash remains syntax-valid.

## Blocked by

- [001 — Inspect a readable v2 agent bundle](001-inspect-readable-v2-bundle.md)
- [002 — Initialize a portable v2 agent bundle](002-initialize-portable-v2-bundle.md)
