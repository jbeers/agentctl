# Install agentctl on Linux amd64

The first supported operator artifact is a native Linux `amd64` executable. It does not require BoxLang, CommandBox, MatchBox, Rust, Java, or a repository checkout at runtime.

Other operating systems and architectures are not currently supported. Confirm that the operator machine reports Linux and `x86_64` before downloading:

```bash
uname -s
uname -m
```

## Download and verify

Choose an exact release version rather than a moving `latest` URL. For the current supported public alpha:

```bash
version=0.1.0-alpha.3
artifact="agentctl-${version}-linux-amd64"
base="https://github.com/jbeers/agentctl/releases/download/v${version}"

mkdir -p "$HOME/Downloads/agentctl-${version}"
cd "$HOME/Downloads/agentctl-${version}"
curl --fail --location --remote-name "$base/$artifact"
curl --fail --location --remote-name "$base/$artifact.sha256"
sha256sum --check "$artifact.sha256"
```

Do not install the executable unless checksum verification reports `OK`. The checksum proves that the downloaded bytes match the named GitHub release asset; this alpha does not yet publish a separate signature.

## Install

```bash
sudo install -m 0755 "$artifact" /usr/local/bin/agentctl
agentctl --version
agentctl --help
```

`--version` reports both the application version and the exact source revision embedded by the release build.

Continue with [Prerequisites](prerequisites.md) and [Create your first agent](first-agent.md). Application versioning does not change the bundle schema: existing valid version 2 bundles remain readable and require no migration.

## Upgrade

Read the target release notes for behavior changes, security-relevant changes, known limitations, and required operator action. Then repeat the download and checksum steps with that exact version and replace the executable:

```bash
sudo install -m 0755 "agentctl-${version}-linux-amd64" /usr/local/bin/agentctl
agentctl --version
```

Upgrading the local executable does not mutate an agent until an explicit lifecycle command is run. Keep the prior verified executable until the new version has completed the checks required by its release notes.

## Uninstall

Before uninstalling, use the appropriate explicit bundles to inspect and safely take down agents you no longer want running. Remember that `down` deliberately retains each billable DigitalOcean Block Storage volume.

Remove only the local executable with:

```bash
sudo rm -f /usr/local/bin/agentctl
```

Removing `agentctl`, its download directory, or a local bundle does **not** delete DigitalOcean Droplets, retained volumes, firewalls, tags, Tailscale nodes, known-host entries, or any other cloud resource. Verify and clean those resources separately before discarding the executable and bundles needed to identify them.
