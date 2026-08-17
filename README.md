# agentctl

`agentctl` provisions disposable Hermes coding agents. The V2 implementation initializes, inspects, diagnoses, brings up, accesses, and safely takes down a private Hermes VM from one portable encrypted bundle.

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
./bin/agentctl agent status --file agents/sample-agent.agent.yml
./bin/agentctl agent open --file agents/sample-agent.agent.yml
./bin/agentctl agent ssh --file agents/sample-agent.agent.yml
./bin/agentctl agent down --file agents/sample-agent.agent.yml
```

Initialization validates SOPS and local decryption before prompting for credentials, generates an agent-specific Ed25519 identity, and publishes the bundle atomically with mode `0600`. Inspection resolves a redacted plan. Doctor checks bundle credentials and local prerequisites. `up` can securely restore local archives into fresh `/opt/data` and disposable `/workdir`, create billable DigitalOcean resources, and succeeds only after private SSH/Tailscale access and Hermes health are ready. `status` reports the same readiness in read-only dependency layers.

See [Agent bundles and inspection](docs/agent-bundles.md), [Bring up an agent](docs/agent-up.md), [Check layered agent health](docs/agent-status.md), [Access a running agent](docs/agent-access.md), [Workspace and Compose](docs/compose-workspace.md), and [Take an agent down safely](docs/agent-down.md).

The V2 lifecycle is complete. The next public-product workstream is tracked in the [V3 roadmap](v3/README.md); it does not introduce a V3 bundle schema.
