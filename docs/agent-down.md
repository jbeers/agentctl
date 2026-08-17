# Take an agent down safely

`agent down` removes disposable compute while retaining the provider volume that contains Hermes state:

```bash
agentctl agent down --file agents/sample-agent.agent.yml
```

This command is destructive: the Droplet and its `/workdir` are deleted. The provider volume `agent-home-<agent-name>` is retained and is reused by a later `agent up`.

## Before running down

Hermes and the operator are responsible for committing and pushing work that must survive. `agentctl` does not inspect Git, determine whether `/workdir` is clean, or back up `/workdir`.

If you need a portable copy of retained Hermes state, run [`agent export`](archives.md#export-a-ready-agent) while the appliance is still fully ready. `down` does not export automatically, and export intentionally excludes `/workdir`.

## Shutdown sequence

When the exact-name Droplet exists, `down`:

1. Uses the generated SSH identity from the explicit encrypted bundle to connect over the effective Tailscale hostname.
2. Gives the Hermes container up to 60 seconds to stop cleanly.
3. Flushes filesystem writes.
4. Unmounts `/agent-dirs/<agent-name>`, which backs Hermes `/opt/data`.
5. Schedules a best-effort Tailscale logout.
6. Deletes only the exact DigitalOcean Droplet.
7. Removes the stale local known-host entry after provider deletion succeeds.

A stop, flush, or unmount failure blocks Droplet deletion. Tailscale logout failure produces a warning but does not block deletion because enrollment uses ephemeral-node cleanup. No lifecycle message is sent to Telegram or another chat platform.

If the Droplet is already absent, the command succeeds without creating a temporary SSH identity or invoking a destructive provider command.

A per-command hostname override can resolve a temporary MagicDNS collision without changing the bundle:

```bash
agentctl agent down \
  --file agents/sample-agent.agent.yml \
  --hostname sample-agent-1
```

Temporary local identity and script files use mode `0600` and are removed on success or failure. Remote shutdown and logout scripts remove themselves and contain no bundle secrets.

After `down`, the retained volume remains billable. Follow [Persistence, billing, and cleanup](persistence.md), and delete a tutorial volume only through the guarded provider procedure in the [first-agent guide](first-agent.md#delete-the-retained-tutorial-volume).
