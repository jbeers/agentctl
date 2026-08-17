# Purge retained state

`agentctl agent purge` irreversibly deletes the exact detached DigitalOcean volume derived from one explicit bundle. It is deliberately separate from `down`: normal teardown continues to retain `/opt/data`, while purge closes storage billing only after repeated provider checks and exact agent-name confirmation.

!!! danger "Permanent deletion"
    Purge destroys Hermes configuration, model and GitHub credentials, memory, sessions, and every other file retained under `/opt/data`. It cannot be undone. `agentctl` does not verify or claim that a backup exists.

## Export before destructive cleanup

If the state may be needed again, export it while the appliance is still fully ready, then take compute down:

```bash
bundle="$HOME/.config/agentctl/agents/tutorial-agent.agent.yml"
backup_directory="$HOME/backups/agentctl"
mkdir -p -m 0700 "$backup_directory"

agentctl agent status --file "$bundle"
agentctl agent export \
  --file "$bundle" \
  --output "$backup_directory/hermes-state.tar"
agentctl agent down --file "$bundle"
```

Validate and protect the mode-`0600` archive under the secret-bearing guidance in [Export and restore state archives](archives.md). A provider volume remains working storage, not an independent backup; only the operator can decide whether the exported copy is sufficient.

## Run guarded purge

Use the same explicit bundle after `down` succeeds:

```bash
agentctl agent purge --file "$bundle"
```

Before reading confirmation, `agentctl` prints that deletion is irreversible, names `agent-home-<agent-name>`, reminds you to verify backup status, and states that it has not verified a backup. Type the **exact, case-sensitive agent name** when prompted. Blank input, a mismatch, Ctrl-C, or non-interactive end-of-input exits without a delete request.

There is no user-facing `--force` option. Internally, purge:

1. Refuses any exact-name Droplet, regardless of power or provisioning state.
2. Requires exactly one exact-name volume.
3. Requires its region and GiB size to match the bundle.
4. Requires the volume to have no Droplet attachments.
5. Records its provider ID before confirmation.
6. Repeats every provider and attachment check after confirmation.
7. Deletes only when the second exact ID matches the first.

Duplicate, attached, replaced, missing-after-confirmation, wrong-region, wrong-size, malformed, or provider-indeterminate results stop before deletion. A volume absent during the initial inspection is a successful no-op and does not prompt.

Successful output reports the deleted volume name and provider ID, says the operation cannot be undone, and explicitly leaves backup status unclaimed. The bundle itself is not deleted; retain it until every associated resource and recovery need is accounted for.

## Billing and remaining cleanup

A successful purge ends billing for that exact retained Block Storage volume. It does not remove a Tailscale node or auth key, local known-host entry, age identity, bundle, exported archive, model credential, or GitHub token. Complete those separate identity and local-file checks from the [first-agent cleanup](first-agent.md#complete-cost-and-identity-cleanup).
