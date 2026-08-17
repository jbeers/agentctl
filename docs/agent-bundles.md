# Agent bundles and inspection

A V2 agent bundle is one YAML file containing readable agent intent and one dedicated encrypted secret subtree. Provider login, the operator's age private identity, and local Tailscale membership stay outside the bundle.

## Initialize a bundle

With no options, initialization starts an interactive wizard:

```bash
agentctl agent init
```

The wizard asks for the agent name, bundle path, DigitalOcean region and size, Tailscale hostname, runtime image, dashboard username, and age recipient. Press Enter to accept a displayed default. A blank age recipient uses a matching SOPS creation rule. The wizard proposes `<agent-name>.agent.yml` but does not scan the current directory or overwrite an existing path. Supplying any option selects the flag-based form, where both `--name` and `--file` remain required.

For the flag-based form, provide the identity and target explicitly:

```bash
agentctl agent init \
  --name sample-agent \
  --file agents/sample-agent.agent.yml \
  --age-recipient age1replace-with-your-public-recipient
```

`--age-recipient` is optional when a matching SOPS creation rule supplies recipients. The selected recipient must include the local operator, because initialization proves that the encrypted bundle can be decrypted before asking for credentials.

Initialization then prompts, with terminal echo disabled, for:

1. A confirmed Tailscale enrollment key.
2. A confirmed Hermes dashboard password.
3. An optional confirmed registry pull token.

Before those prompts, `agentctl` verifies `sops`, `ssh-keygen`, encryption, partial-encryption policy, and local age decryption. It generates a dedicated Ed25519 identity plus Hermes API and dashboard-signing keys. Secret values enter SOPS through standard input, never process arguments. Provider credentials and age private identities are never copied into the bundle.

The target must not exist. The completed bundle is published atomically with mode `0600`; temporary encrypted bundle and SSH-key files are also mode `0600` and are removed after success or failure.

Public choices can be supplied during initialization:

```bash
agentctl agent init \
  --name sample-agent \
  --file agents/sample-agent.agent.yml \
  --region fra1 \
  --size s-2vcpu-4gb \
  --hostname sample-agent \
  --runtime-image ghcr.io/example/hermes:sha-0123456 \
  --dashboard-username operator
```

## Minimal bundle

```yaml
version: 2
identity:
  name: sample-agent
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
  image: ghcr.io/jbeers/agentctl@sha256:28b6b1715c7d55ba50fda783c49d40030ce10a3e901bd7bd5eec2c812621053f
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
| Runtime image | `ghcr.io/jbeers/agentctl@sha256:28b6b1715c7d55ba50fda783c49d40030ce10a3e901bd7bd5eec2c812621053f` | `--runtime-image` |
| Access method | `openssh-over-tailscale` | None |
| Working-state strategy | `provider-volume` | None |
| Working-state size | `10GiB` | None |
| Initial dashboard username | `admin` | None |

The built-in runtime is a public Linux `amd64` image and pulls anonymously; the normal path needs no GHCR credential. A non-`latest` private image remains supported through `runtime.image` or `--runtime-image`, with its optional SOPS-protected `secrets.registryToken` used only for host-side pull authentication.

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

`agent init` is the canonical way to create the encrypted file. If editing it later with SOPS, never first save credentials in a plaintext bundle. `agentctl` runs SOPS with argv-based commands, reads decrypted YAML directly from command output, keeps it in memory, and never writes a decrypted bundle.

Inspection prints only these states:

- `configured` for operator-supplied Tailscale, registry, and dashboard credentials
- `generated` for the agent SSH identity and generated Hermes keys
- `missing` when a field is empty or absent

Neither normal output nor errors include secret values, private-key material, or SOPS ciphertext.

## Inspect

```bash
agentctl agent inspect --file agents/sample.agent.yml
```

There is no current-directory discovery and no lifecycle environment-variable precedence. The command reads the selected file and may invoke local `sops`; it does not invoke DigitalOcean, SSH, SCP, Tailscale, or a browser. `--verbose` reports only whether the validated bundle was plaintext or SOPS-encrypted.

Per-command archive intent can be included without storing paths in the bundle:

```bash
agentctl agent inspect \
  --file agents/sample.agent.yml \
  --state-archive /protected/state.tar \
  --workspace-archive /protected/workspace.tar
```

Inspection reports each archive as provided but does not print its path or read the archive. `agent up --state-archive <path>` restores validated Hermes state into empty `/opt/data`; `--workspace-archive <path>` seeds empty, disposable `/workdir`. Both may be supplied together. See [Restore state and seed a workspace](archives.md).

The lifecycle summary makes retention explicit: `down` will discard the Droplet and `/workdir`, while retaining the provider volume mounted into Hermes at `/opt/data`.

## Rotate encrypted credentials

`agentctl agent rotate --file <bundle> --credential <name>` updates one supported encrypted value without exposing old or new credentials. It never discovers a bundle implicitly or mutates a running appliance. See [Rotate encrypted bundle credentials](credential-rotation.md) for selections, registry-token removal, atomic publication, and when a later `up` consumes each replacement.

## Doctor

```bash
agentctl agent doctor --file agents/sample-agent.agent.yml
```

Doctor performs no resource creation or mutation. It checks:

- Local `doctl`, `sops`, `ssh`, `scp`, and `ssh-keygen` availability.
- An `xdg-open` or `open` browser launcher.
- SOPS/age decryption and required bundle credentials.
- The generated SSH private key using a temporary mode-`0600` file.
- DigitalOcean authentication using the read-only `doctl account get` command.

Failures are labeled as a local `prerequisite`, `bundle`, or `provider authentication` problem. Tool output, decrypted values, private-key material, and provider credentials are never included in doctor output.
