# Export and restore state archives

`agentctl agent export` creates a portable archive of a ready agent's durable `/opt/data`. `agent up` accepts that state archive and an independently created workspace archive:

- `agent export --output <path>` safely stops Hermes, archives `/opt/data`, restores runtime health, and atomically publishes a new local mode-`0600` file.
- `--state-archive <path>` restores durable Hermes state directly into empty `/opt/data`.
- `--workspace-archive <path>` seeds project files directly into empty, disposable `/workdir`.

Export does not include `/workdir`, create automatic backups, or run as part of `down`.

## Export a ready agent

Create the private destination directory first and choose a path that does not exist:

```bash
bundle="$HOME/.config/agentctl/agents/tutorial-agent.agent.yml"
backup_directory="$HOME/backups/agentctl"
mkdir -p -m 0700 "$backup_directory"

agentctl agent status --file "$bundle"
agentctl agent export \
  --file "$bundle" \
  --output "$backup_directory/hermes-state.tar"
```

Export requires the exact agent to be fully `ready`: one active Droplet, the expected attached volume, private SSH/Tailscale access, a running Hermes container, and healthy gateway and dashboard layers. An absent, provisioning, duplicated, mismatched, detached, or unhealthy appliance is refused before Hermes is stopped.

The output path is always explicit. `agentctl` never invents a backup name, scans the current directory, or overwrites an existing file, directory, symlink, device, or other target. The parent directory must already exist.

On the VM, export gives Hermes a bounded clean stop, synchronizes `/opt/data`, creates a mode-`0600` tar archive rooted directly at that directory, and omits only an empty ext4 `lost+found`. Runtime-generated symlinks whose targets leave `/opt/data` are omitted rather than dereferenced into the image; user data is never followed outside the durable root. A non-empty or unsafe `lost+found` is refused rather than discarded. Hermes is restarted and both private health endpoints are checked before ordinary success.

The received bytes are copied and validated through the same path, link, type, size, and SHA-256 boundary used by restore. The validated copy is synchronized and published atomically at mode `0600`. Normal and verbose output omit the archive path, digest, entries, and bytes.

If transfer or validation fails, the requested output remains absent and local/remote temporary files are removed. The remote script makes a bounded restart attempt after a stop, archive, signal, or synchronization failure. If validation and publication succeed but container, Tailscale, gateway, or dashboard recovery fails, the command returns nonzero **without deleting the completed backup**; investigate the named runtime layer and preserve the archive.

## Restore or seed a fresh target

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

Restore and seed output reports stages without archive entries. For those operator-supplied inputs, `--verbose` may additionally report the source path, byte size, and SHA-256 digest after successful validation. Export output remains stricter and omits its destination path, size, digest, and entries even with `--verbose`. Treat archives and even their paths as secret-bearing.

## State behavior

A restored non-empty `/opt/data/.env` remains authoritative. Bundle initial values fill only required settings that are missing or empty. Later `up` reconciliation preserves those existing non-empty settings.

State archives may contain model-provider keys, GitHub authentication, Hermes configuration, memory, and conversation history. Store them with permissions and backup controls suitable for credentials. Their mode-`0600` local file, private path, and omitted output do not make them safe to publish.

A successful export is a point-in-time portable copy. The attached DigitalOcean volume remains live working storage, not an independent backup, and export does not delete or detach it.

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
