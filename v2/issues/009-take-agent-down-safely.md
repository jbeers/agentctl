# Take an agent down safely

- **Type:** AFK
- **User stories:** 40, 50–52, 56–62

## Parent

[agentctl V2 PRD](../PRD.md)

## What to build

Implement the V2 `down` contract: stop and remove disposable compute while retaining authoritative Hermes state. Adapt the prototype's safe teardown path to the V2 bundle and generated SSH identity, remove infrastructure-owned messaging behavior, and make workspace loss explicit.

`agentctl` does not inspect or modify Git. This command protects mounted Hermes state; it cannot promise that unpushed `/workdir` contents are safe.

## Acceptance criteria

- [x] `agent down` requires an explicit V2 bundle and uses its exact provider identity and access settings.
- [x] An already absent Droplet is reported as absent and the command succeeds without materializing SSH credentials or invoking destructive commands.
- [x] For a present Droplet, the encrypted SSH identity is handled through the same temporary-file safety path as `agent ssh`.
- [x] Hermes is stopped cleanly with a bounded timeout before state preparation continues.
- [x] Filesystem writes are flushed and the persistent state mount is unmounted before Droplet deletion.
- [x] Failure to stop Hermes safely, flush, or unmount blocks compute deletion and returns a focused error.
- [x] Tailscale logout is scheduled after state is safe; logout failure is a warning and relies on ephemeral-node cleanup rather than blocking deletion.
- [x] Only the exact Droplet is deleted. The provider volume is neither deleted nor reformatted.
- [x] Output explicitly states that the provider volume was retained and `/workdir` was discarded.
- [x] Output states that Git commit/push safety is Hermes/operator responsibility and was not checked by `agentctl`.
- [x] No readiness or shutdown message is sent directly to Telegram or another chat platform by infrastructure scripts.
- [x] The stale known-host entry for the deleted disposable host is removed only after successful deletion.
- [x] Private keys, environment content, and remote payloads remain absent from output and command arguments.
- [x] Fake-runner tests cover absent success, normal teardown ordering, stop failure, unmount failure, logout warning, provider deletion failure, retained-volume behavior, key cleanup, and redaction.
- [x] Generated shutdown/logout scripts remain valid Bash and remove their remote temporary files.

## Blocked by

- [003 — Bring up a private v2 agent](003-bring-up-private-v2-agent.md)
