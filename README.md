# agentctl

`agentctl` provisions disposable Hermes coding agents. The current V2 slice can inspect a readable agent bundle without changing local or cloud resources.

## Build and test

Requirements: BoxLang, CommandBox, and the local or installed MatchBox compiler.

```bash
box install
box run-script test
box run-script build
```

The native executable is written to `bin/agentctl`.

## Inspect a bundle

Bundle selection is always explicit:

```bash
./bin/agentctl agent inspect --file agents/sample.agent.yml
```

Inspection validates the versioned schema, resolves visible defaults and CLI overrides, derives resource names, and reports persistence behavior. Secret values and ciphertext are never displayed. An encrypted bundle also requires `sops` and a usable local age identity.

See [Agent bundles and inspection](docs/agent-bundles.md) for the schema, defaults, security boundary, and command options.
