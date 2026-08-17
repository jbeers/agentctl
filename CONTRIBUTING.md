# Contributing

`agentctl` is developed publicly as an alpha. Contributions should preserve the completed V2 behavior and follow the active roadmap in [`v3/`](v3/README.md).

## Development prerequisites

- BoxLang
- CommandBox
- MatchBox
- Bash
- Git
- Python 3.13 for documentation changes

Install the declared development dependencies, run the deterministic suite, and build the native executable:

```bash
box install
box run-script test
box run-script build
```

The generated executable is ignored under `bin/` and must not be committed.

For documentation changes, install the pinned site generator in an isolated Python environment and run the strict site check:

```bash
python3 -m venv /tmp/agentctl-docs
/tmp/agentctl-docs/bin/pip install -r requirements-docs.txt
PATH="/tmp/agentctl-docs/bin:$PATH" scripts/check-docs /tmp/agentctl-site
```

The check rejects broken internal links, missing navigation targets, unresolved release placeholders, and drift between documented and built-in release/runtime defaults.

## Change rules

- Start from one roadmap issue and deliver the smallest complete user-visible slice.
- Keep `agentctl` focused on Hermes, DigitalOcean, Tailscale, explicit V2 bundles, and rootless Podman.
- Reuse existing services and standard platform behavior before adding abstractions or dependencies.
- Do not add compatibility layers for obsolete prototype behavior.
- Do not introduce implicit bundle discovery, arbitrary host scripts, broad environment precedence, rootful container access, or provider frameworks without an approved requirement.
- Preserve trust-boundary validation, exact provider identity checks, host-key policy, redaction, restrictive temporary files, and cleanup on every exit path.
- Document user-visible behavior in `docs/`; avoid implementation tours in user documentation.

## Tests

Tests should assert observable behavior rather than private helper structure. Use the existing fake command runner for provider, SSH, SCP, browser, and SOPS interactions. Nontrivial generated Bash must be syntax-checked. Secret tests assert that values are absent from argv, output, errors, and temporary files.

Use only synthetic credentials and resource names. Never use any name containing the protected production-test term documented in `AGENTS.md`.

Live DigitalOcean, Tailscale, GHCR publication, public repository, or volume-deletion work is not part of an ordinary local test. It requires explicit maintainer approval and a written cleanup plan.

## Documentation and pull requests

Before proposing a change:

1. Run the complete TestBox suite.
2. Run the native build and smallest relevant native smoke check.
3. Build the strict documentation site when Markdown, release metadata, or runtime defaults change.
4. Run `git diff --check`.
5. Confirm no bundle, credential, generated binary, site output, test result, or local temporary file is staged.
6. Update the issue acceptance criteria and roadmap status in the same change when the slice is complete.

A change should explain the user-visible behavior, its runnable verification, and any deliberate limitation. Security concerns must follow [SECURITY.md](SECURITY.md), not a public review thread.
