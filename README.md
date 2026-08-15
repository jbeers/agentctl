# agentctl

`agentctl` provisions disposable Hermes coding agents. The V2 implementation initializes, inspects, diagnoses, brings up, and safely takes down a private Hermes VM from one portable encrypted bundle.

## Build and test

Requirements: BoxLang, CommandBox, and the local or installed MatchBox compiler.

```bash
box install
box run-script test
box run-script build
```

The native executable is written to `bin/agentctl`.

## Initialize and inspect a bundle

Run argument-free initialization for an interactive wizard:

```bash
./bin/agentctl agent init
```

The wizard asks for the agent name, target bundle, public settings, and age recipient, with defaults where available. The flag-based form remains available:

```bash
./bin/agentctl agent init \
  --name sample-agent \
  --file agents/sample-agent.agent.yml \
  --age-recipient age1replace-with-your-public-recipient

./bin/agentctl agent inspect --file agents/sample-agent.agent.yml
./bin/agentctl agent doctor --file agents/sample-agent.agent.yml
./bin/agentctl agent up --file agents/sample-agent.agent.yml
./bin/agentctl agent open --file agents/sample-agent.agent.yml
./bin/agentctl agent down --file agents/sample-agent.agent.yml
```

Initialization validates SOPS and local decryption before prompting for credentials, generates an agent-specific Ed25519 identity, and publishes the bundle atomically with mode `0600`. Inspection resolves a redacted plan. Doctor checks bundle credentials, local tools, the SSH identity, browser support, and read-only DigitalOcean authentication. `up` can securely restore a local state archive into fresh `/opt/data`, create billable DigitalOcean resources, and succeeds only after private SSH/Tailscale access and Hermes health are ready.

See [Agent bundles and inspection](docs/agent-bundles.md), [Bring up an agent](docs/agent-up.md), [Workspace and Compose](docs/compose-workspace.md), and [Take an agent down safely](docs/agent-down.md).
