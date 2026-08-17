# Restore state and seed a workspace

`agent up` accepts two independent local tar archives:

- `--state-archive <path>` restores durable Hermes state directly into empty `/opt/data`.
- `--workspace-archive <path>` seeds project files directly into empty, disposable `/workdir`.

Both archives are optional and may be supplied together. Paths are invocation-only and are never stored in the bundle.

## Use only fresh destinations

```bash
agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --state-archive recovery/hermes-state.tar

agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --workspace-archive recovery/workspace.tar

agentctl agent up \
  --file agents/sample-agent.agent.yml \
  --state-archive recovery/hermes-state.tar \
  --workspace-archive recovery/workspace.tar
```

Relative paths resolve from the directory where `agentctl` is invoked. Archive entries are placed directly under their destination; do not add a wrapper directory.

A state archive is accepted only when `/opt/data` has no content other than a fresh ext4 `lost+found`. A workspace archive is accepted only when `/workdir` is empty. Restoration never merges, skips, or overwrites. Use a different fresh agent/volume when retained state already exists.

Supplying both archives is one operation: all requested destinations are checked before extraction. If either extraction fails, Hermes remains stopped and content extracted by that operation is removed from both targets.

## Validation boundary

Before provider inspection or mutation, `agentctl` copies each source into a separate local mode-`0600` temporary file and validates those exact bytes. Validation rejects:

- Malformed tar data
- Absolute paths or parent traversal
- Duplicate destinations
- Symbolic or hard links that escape the destination
- Devices, FIFOs, sockets, and other special entries

Safe regular files, directories, symbolic links, hard links, and executable modes are supported. Unsafe ownership and permission bits are discarded.

The validated copies travel over SCP as mode-`0600` remote temporary files and are validated again on the host before extraction. Local and remote temporary files are removed on success or failure. Archive validation requires local `python3`; host enrollment installs its own Python.

Normal output reports stages without archive paths or entries. `--verbose` may additionally report the source path, byte size, and SHA-256 digest after successful validation. Treat archives and even their paths as secret-bearing.

## State behavior

A restored non-empty `/opt/data/.env` remains authoritative. Bundle initial values fill only required settings that are missing or empty. Later `up` reconciliation preserves those existing non-empty settings.

State archives may contain model-provider keys, GitHub authentication, Hermes configuration, memory, and conversation history. Store them with permissions and backup controls suitable for credentials.

`agentctl` can restore state but cannot yet export `/opt/data`. A DigitalOcean volume is working durability, not an independent backup.

## Workspace behavior

Workspace seeding does not inspect or change Git remotes, branches, credentials, commits, or dirty state. The seeded files remain disposable even though they arrived from an archive.

Commit and push work that must survive `down` or a cold rebuild. Compose named volumes also remain Droplet-local unless a project explicitly uses another persistence mechanism.

## Inspect archive intent safely

Inspection can report that each archive was provided without reading it or printing its path:

```bash
agentctl agent inspect \
  --file agents/sample-agent.agent.yml \
  --state-archive recovery/hermes-state.tar \
  --workspace-archive recovery/workspace.tar
```

See [Bring up an agent](agent-up.md) for resource reconciliation and [Persistence, billing, and cleanup](persistence.md) for destination lifetimes.
