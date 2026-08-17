# Troubleshooting

Troubleshoot in dependency order. Do not jump to manual VM repair when an earlier local, bundle, provider, storage, or Tailscale layer is unhealthy.

Start with the same explicit bundle used for `up`:

```bash
agentctl --version
agentctl agent inspect --file agents/sample-agent.agent.yml
agentctl agent doctor --file agents/sample-agent.agent.yml
agentctl agent status --file agents/sample-agent.agent.yml
```

`inspect` is local and non-mutating, `doctor` adds read-only prerequisite and account checks, and `status` reads the live layers without reconciling them. Status stops checks after the first failed dependency and labels later layers `not checked`.

## 1. Prerequisite layer

Typical failures mention a missing `doctl`, `sops`, `ssh`, `scp`, `ssh-keygen`, browser launcher, or Python archive validator.

- Confirm Linux `x86_64` and the latest supported `agentctl --version`.
- Run the command inventory in [Prerequisites](prerequisites.md#openssh-browser-and-local-commands).
- Confirm `doctl account get` succeeds without passing a token on the command line.
- Confirm `tailscale status` shows the operator in the intended tailnet.
- Confirm `age-keygen -y ~/.config/sops/age/keys.txt` can read the intended identity without printing the private key.
- Install `python3` only when an archive option is used.

`doctor` reports tool categories, not raw external output. Run upstream diagnostic commands deliberately and review their output before sharing any part of it.

## 2. Bundle layer

Typical failures include unsupported schema, unknown fields, missing credentials, SOPS decryption failure, invalid agent names, mutable runtime tags, and unusable SSH keys.

- Always pass the intended `--file`; there is no current-directory discovery.
- Confirm the file is mode `0600` and the local age identity is the recipient used by SOPS.
- Use `agent inspect` rather than `sops --decrypt` when diagnosing public intent. Inspection never prints secret values.
- Keep public fields outside `secrets` and every non-empty secret inside the SOPS-encrypted `secrets` subtree.
- Use a runtime digest or non-`latest` tag.
- Recreate a failed new tutorial bundle with `agent init`; do not hand-build private keys or plaintext secret YAML.

Never attach the bundle or its ciphertext to a public issue.

## 3. Provider layer

Provider failures occur before private SSH and may be authentication, exact identity, region, size, firewall, tag, or API availability problems.

- Run `doctl account get` and verify the active context has the required account and resource permissions.
- Check the DigitalOcean status page for provider incidents.
- Use the control panel or read-only `doctl` lists to identify exact-name resources.
- Multiple exact-name Droplets or volumes are intentionally refused; remove ambiguity only after independently identifying every resource.
- A volume in a different region, at a different size, or attached to another Droplet is never silently adopted.
- A provider API error is indeterminate, not proof that a resource is absent. Do not create or delete replacements while the account state is uncertain.

`up` is idempotent for one unambiguous exact-name appliance. Rerun it after correcting authentication or provider state.

## 4. Storage layer

Status reports a missing, mismatched, detached, or incorrectly attached working volume before runtime checks.

- Expected volume name: `agent-home-<agent-name>`.
- Confirm its region and GiB size match the inspected plan.
- Confirm it is attached only to the exact managed Droplet while the agent is up.
- Do not format, detach, resize, or delete a volume to work around an `up` failure.
- A `down` failure while stopping Hermes, flushing writes, or unmounting state deliberately blocks Droplet deletion. Preserve both resources and investigate before retrying.

The provider volume backs `/opt/data`; `/workdir` is not on that volume.

## 5. Tailscale and SSH layer

Typical symptoms are MagicDNS lookup failure, SSH timeout, missing Tailscale IPv4, ACL denial, or changed host key.

- Confirm the operator and VM are in the same intended tailnet.
- Confirm MagicDNS and ACLs allow TCP 22, 8642, and 9119 from the operator.
- Check the exact hostname in the Tailscale admin console. An approved temporary hostname collision may be addressed with `--hostname` for that invocation.
- New-host enrollment needs a valid reusable auth key. A one-use, expired, revoked, unapproved, or incorrectly tagged key cannot enroll a replacement Droplet.
- Do not connect through the public IPv4 address; it is outside the supported route and public inbound firewall policy.

A changed SSH host key is refused. If provider inspection proves the disposable Droplet was legitimately replaced, run:

```bash
agentctl agent up --file agents/sample-agent.agent.yml
```

That exact-resource reconciliation owns known-host replacement. Do not use `StrictHostKeyChecking=no`, and do not have `status` or `ssh` erase the mismatch.

## 6. Container layer

Focused runtime errors include:

- `host registry login failed; verify the registry pull credential`
- `pulling the selected Hermes runtime image failed`
- `selected Hermes runtime image does not satisfy the Compose contract`
- `configuring the rootless Podman socket failed`
- `normalizing rootless runtime ownership failed`
- `runtime credential payload or required Hermes settings validation failed`
- `writing managed Hermes runtime configuration failed`
- `starting the Hermes runtime container failed`

For the built-in public runtime, leave the registry token blank. Confirm outbound access to GHCR and rerun `up`. For a private override, confirm the immutable image reference and narrowly scoped host pull token; the token is not available inside Hermes.

Do not install a second daemon or switch to rootful Podman. The supported contract is the `agent` user's rootless socket plus `podman-compose` inside Hermes. If an image override lacks that client, select a compatible immutable image or return to the built-in digest.

Use `agent ssh` only after the SSH layer is healthy. Review focused container state without copying environment files, payloads, credentials, or raw unreviewed logs into support reports.

## 7. Gateway layer

`Hermes gateway did not become healthy` means the container started but private health on port 8642 did not become ready.

- Confirm the container layer is healthy first.
- Confirm the VM has a usable Tailscale IPv4 address.
- Confirm tailnet ACLs permit operator access to 8642.
- Rerun `up` to reconcile the managed launcher and container.
- Model-provider inference is separate: an absent model key can prevent a useful chat without making the infrastructure gateway health endpoint fail.

Do not expose 8642 publicly to bypass a private-route problem.

## 8. Dashboard layer

A healthy gateway with an unhealthy or unreachable dashboard narrows the problem to port 9119, browser launch, tailnet policy, or dashboard authentication.

- Run `agent status` and confirm only the dashboard layer fails.
- Confirm `xdg-open` exists and a graphical browser is available.
- Open only `http://<effective-tailscale-hostname>:9119` from a tailnet member.
- Confirm ACL access to TCP 9119.
- Use the dashboard username from `inspect` and the password entered during `init`.
- Do not place credentials in the URL or browser command.

`agent open` launches a URL but does not bypass dashboard authentication.

## 9. Archive layer

Archive failures occur before provider mutation when local validation fails, or before Hermes startup when remote validation/destination checks fail.

Common focused errors include:

- `persistent state is not empty; state archive restore was refused`
- `workspace is not empty; workspace archive seeding was refused`

- Confirm local `python3` is available.
- Confirm the selected file is a valid tar archive with relative, unique, non-escaping entries.
- Restore only into fresh destinations. Archives never merge with retained `/opt/data` or an existing `/workdir`.
- Do not weaken validation for absolute paths, traversal, escaping links, devices, FIFOs, or sockets.
- When both archives are requested, correct both before retrying; failed extraction cleanup keeps Hermes stopped.

Normal output omits paths and contents. Treat archive filenames, hashes, and verbose output as private. See [Restore state and seed a workspace](archives.md).

## Safe recovery and support

If resource identity, attachment, or provider state is uncertain, stop. Preserving an extra resource is safer than deleting the wrong state.

A safe support report includes only:

- `agentctl` version and source revision
- Supported operator platform
- Command name
- Redacted failed layer and focused error
- Whether the exact compute and retained volume are believed to exist
- A synthetic reproducer when possible

Do not include bundles, SOPS ciphertext, private hostnames, public IPs, provider IDs, tokens, private keys, `.env` files, archive paths or contents, or unreviewed verbose logs. Use the [support policy](https://github.com/jbeers/agentctl/blob/main/SUPPORT.md); report vulnerabilities privately under the [security policy](https://github.com/jbeers/agentctl/blob/main/SECURITY.md).
