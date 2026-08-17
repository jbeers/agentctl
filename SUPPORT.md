# Support

## Current support level

`agentctl` is pre-public-alpha software. Support is best effort and currently covers the latest development revision on the documented supported platform. There is no service-level agreement, hosted control plane, paid support contract, or guarantee that an unreleased interface will remain unchanged.

After public-alpha publication, only the latest public-alpha release will be supported unless release notes state otherwise.

## Before asking for help

1. Read the [project status and limitations](docs/project-status.md).
2. Run `agentctl agent doctor` with the same explicit bundle.
3. Run read-only layered `agentctl agent status` when an agent exists.
4. Check the guide for the failed prerequisite, provider, storage, Tailscale/SSH, container, gateway, dashboard, or archive layer.
5. Reproduce with the latest supported release when safe.

## Safe reports

A useful support request includes:

- `agentctl` version or source revision
- operator platform
- command name
- redacted layer and focused error
- whether compute and retained state currently exist
- the smallest synthetic reproduction

Do not post agent bundles, SOPS ciphertext, decrypted values, private keys, environment files, archive paths or contents, provider credentials, Tailscale keys, registry tokens, public IP addresses, or raw verbose logs that have not been reviewed.

Normal bug reports and documentation requests belong in the [agentctl issue tracker](https://github.com/jbeers/agentctl/issues). Security reports must follow [SECURITY.md](SECURITY.md) and must not be filed publicly.

## Boundaries

The project supports `agentctl` behavior, its documented runtime image, and its generated DigitalOcean lifecycle. DigitalOcean account administration, Tailscale account policy, Hermes model-provider accounts, GitHub permissions, SOPS key recovery, and modified runtime images remain the responsibility of those upstream systems and the operator.
