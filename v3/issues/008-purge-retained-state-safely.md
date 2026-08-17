# Purge retained state safely

- **Type:** HITL
- **User stories:** 61–64

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Add an explicitly destructive lifecycle command that removes only the exact retained provider volume for one bundle after compute is already absent. This closes the billing-cleanup path without changing `down`: normal teardown still retains state, while purge requires deliberate agent-name confirmation and refuses every ambiguous or attached resource state.

A live acceptance deletion requires separate operator approval after resource and backup review.

## Acceptance criteria

- [x] Purge requires an explicit bundle and never discovers a target from the current directory.
- [x] Before prompting, output states that Hermes state will be irreversibly deleted, identifies the derived volume name, and reminds the operator to verify backup status.
- [x] The operator must type the exact agent name; blank, mismatched, interrupted, or non-interactive input does not mutate provider resources.
- [x] Purge refuses while an exact-name Droplet exists, regardless of provider power state.
- [x] Purge requires exactly one expected volume with matching name, region, configured size, and no Droplet attachments.
- [x] Duplicate, attached, wrong-region, wrong-size, malformed, or provider-indeterminate results fail before deletion.
- [x] No `--force` path bypasses identity, attachment, duplicate, region, size, provider-health, or confirmation checks.
- [x] An already-absent exact volume is a successful, clearly reported no-op.
- [x] Only the exact provider volume identifier established before confirmation is sent to the delete command.
- [x] Successful output reports the deleted identifier and states that the operation cannot be undone; it does not claim that a backup exists.
- [x] `down` behavior and output remain non-destructive and continue to retain the volume.
- [x] Tests cover every refusal boundary, confirmation behavior, provider changes between inspection and deletion, exact argv construction, absent idempotence, redaction, and cleanup.
- [x] Documentation presents state export before purge and includes purge in final tutorial billing cleanup.
- [x] Operator-approved live verification inspects the detached test volume and backup status before authorizing its deletion.

## Implementation evidence

- `agent purge --file <bundle>` accepts only an explicit bundle; the parser has no user-facing force option.
- `PurgeService.prepare` refuses every exact-name Droplet and requires one exact-name, matching-region, matching-size, detached volume before the warning and prompt are shown.
- Warning output names the derived volume, states irreversible Hermes-state deletion, asks the operator to verify backup status, and explicitly says no backup was verified or claimed.
- Confirmation uses case-sensitive exact comparison. Blank, mismatched, and non-interactive input stops before the second provider read or any delete request.
- After confirmation, every compute, volume, configuration, attachment, and provider-health check is repeated. A changed or absent volume ID is refused, and deletion receives only the ID established before confirmation.
- The suite passes 103/103 checks, including all refusal states, provider changes, exact delete argv, absent idempotence, warning/output behavior, current `doctl` GiB size formatting, redaction, and unchanged non-destructive `down` coverage.
- A native fake-provider exercise proved warning-before-prompt order, non-interactive and case-mismatch refusal, repeated reads, and the sole exact delete argv `compute volume delete <established-id> --force` without contacting DigitalOcean.
- Live acceptance created only the approved synthetic `agent-home-agentctl-purge-acceptance` 10 GiB volume in `nyc3`. Initial candidate inspection safely refused current `doctl` output (`10 GiB`) as malformed before prompting or deleting; the smallest regression and parser correction were committed before rebuilding the candidate.
- The replacement candidate reached the warning and prompt. Non-interactive input refused deletion and left the volume unchanged. Review then confirmed exact provider ID `1eac6681-9a79-11f1-a771-e66fff52f8cd`, one exact volume, matching region and size, zero attachments, no exact-name Droplet, no filesystem, no provider snapshot, and no user data or recovery need.
- After separate operator approval, purge repeated all checks and deleted only that exact ID. Direct provider inspection found zero exact volumes and Droplets, and a second purge returned the documented successful absent no-op without prompting.
- [Purge retained state](../../docs/purge.md), persistence/security guidance, and the first-agent cleanup now put export before purge and explain every irreversible boundary.

## Blocked by

None — complete.
