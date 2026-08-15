# Agent bundles and inspection

A V2 agent bundle is one YAML file containing readable agent intent and one dedicated encrypted secret subtree. Provider login, the operator's age private identity, and local Tailscale membership stay outside the bundle.

## Minimal bundle

```yaml
version: 2
identity:
  name: sample-agent
runtime:
  image: ghcr.io/example/hermes:sha-0123456
secrets: {}
```

Agent names use lowercase letters, numbers, and hyphens, begin and end with a letter or number, and are at most 63 characters. Runtime images must use a non-`latest` tag or a SHA-256 digest.

A bundle can make all intent explicit:

```yaml
version: 2
identity:
  name: sample-agent
compute:
  provider: digitalocean
  region: nyc3
  size: s-4vcpu-8gb
state:
  strategy: provider-volume
  size: 10GiB
access:
  method: openssh-over-tailscale
  hostname: sample-agent
runtime:
  image: ghcr.io/example/hermes:sha-0123456
hermes:
  initial:
    dashboardUsername: admin
secrets: {}
```

The schema is strict. Unknown keys, unsupported versions, wrong types, and a missing `identity.name` stop inspection. Empty optional strings are treated as unset rather than overriding a default.

## Effective values

| Value | Built-in default | CLI override |
| --- | --- | --- |
| Compute provider | `digitalocean` | None |
| Region | `nyc3` | `--region` |
| Compute size | `s-4vcpu-8gb` | `--size` |
| Tailscale hostname | Agent name | `--hostname` |
| Runtime image | `ghcr.io/jbeers/cloud-agent-coder:sha-dfb0aaa` | `--runtime-image` |
| Access method | `openssh-over-tailscale` | None |
| Working-state strategy | `provider-volume` | None |
| Working-state size | `10GiB` | None |
| Initial dashboard username | `admin` | None |

CLI input takes precedence over a non-empty bundle value, which takes precedence over the built-in default. Inspection labels each effective value as `CLI argument`, `bundle`, or `built-in default`.

The Droplet name is the agent name. The retained volume name is `agent-home-<agent-name>`.

## Secrets and SOPS

Only these keys are accepted under `secrets`:

```yaml
secrets:
  sshPrivateKey: ""
  tailscaleAuthKey: ""
  registryToken: ""
  hermes:
    apiServerKey: ""
    dashboardPassword: ""
    dashboardSecret: ""
```

A plaintext bundle may omit these values or leave them empty. Non-empty secret values must be protected by SOPS. Configure SOPS to encrypt the `secrets` subtree while leaving all other intent readable, for example:

```yaml
creation_rules:
  - path_regex: .*\.agent\.yml$
    encrypted_regex: ^secrets$
    age: age1replace-with-an-authorized-recipient
```

Use your normal SOPS editing workflow. Never first save credentials in a plaintext bundle. `agentctl` runs SOPS with an argv-based command, reads decrypted YAML directly from command output, keeps it in memory, and never writes a decrypted bundle.

Inspection prints only these states:

- `configured` for operator-supplied Tailscale, registry, and dashboard credentials
- `generated` for the agent SSH identity and generated Hermes keys
- `missing` when a field is empty or absent

Neither normal output nor errors include secret values, private-key material, or SOPS ciphertext.

## Inspect

```bash
./bin/agentctl agent inspect --file agents/sample.agent.yml
```

There is no current-directory discovery and no lifecycle environment-variable precedence. The command reads the selected file and may invoke local `sops`; it does not invoke DigitalOcean, SSH, SCP, Tailscale, or a browser. `--verbose` reports only whether the validated bundle was plaintext or SOPS-encrypted.

Per-command archive intent can be included without storing paths in the bundle:

```bash
./bin/agentctl agent inspect \
  --file agents/sample.agent.yml \
  --state-archive /protected/state.tar \
  --workspace-archive /protected/workspace.tar
```

Inspection reports each archive as provided but does not print its path or read the archive. Archive restoration is added by later lifecycle work.

The lifecycle summary makes retention explicit: `down` will discard the Droplet and `/workdir`, while retaining the provider volume mounted into Hermes at `/opt/data`.
