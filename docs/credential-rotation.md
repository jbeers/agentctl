# Rotate encrypted bundle credentials

`agentctl agent rotate` replaces one supported credential in an existing SOPS-encrypted version 2 bundle. It is write-only: the command never prints the old value, the replacement, ciphertext, or another decrypted bundle credential.

Rotation always requires an explicit bundle and credential selection:

```bash
bundle="$HOME/.config/agentctl/agents/tutorial-agent.agent.yml"

agentctl agent rotate --file "$bundle" --credential tailscale-auth-key
agentctl agent rotate --file "$bundle" --credential registry-token
agentctl agent rotate --file "$bundle" --credential dashboard-password
```

Each replacement is entered twice through a hidden terminal prompt. A confirmation mismatch returns to the prompt before any bundle update starts. Pressing Ctrl-C cancels without changing the bundle.

The supported credential names are deliberately limited:

| Selection | Bundle value | When a running appliance changes |
| --- | --- | --- |
| `tailscale-auth-key` | Tailscale enrollment key | Never. The key is consumed only by cloud-init when `up` creates and enrolls a fresh Droplet. |
| `registry-token` | Optional host-only registry pull token | The next `up` uses it during runtime reconciliation and image pull. |
| `dashboard-password` | Hermes dashboard password | The next `up` reconciles Hermes configuration and restarts the runtime with the replacement. |

Rotation itself does not contact DigitalOcean, Tailscale, or the agent VM. Run `up` separately when you intend to apply a registry or dashboard replacement to a running appliance.

## Remove a registry token

Removal is an explicit flag, not an empty secret prompt:

```bash
agentctl agent rotate \
  --file "$bundle" \
  --credential registry-token \
  --remove
```

No prompt is shown for this branch. The public default runtime needs no registry token. Do not remove the token while selecting a private image that requires authentication; its next pull will fail.

`--remove` is refused for the Tailscale key and dashboard password because both are required for the supported lifecycle.

## Tailscale expiry and cold rebuilds

A Tailscale auth key cannot enroll a new node after it expires or is revoked. Expiry of the auth key does not disconnect a node that already enrolled with it. Follow Tailscale's [auth-key guidance](https://tailscale.com/kb/1085/auth-keys) and keep the reusable, ephemeral, narrowly scoped settings described in [Prerequisites](prerequisites.md).

Changing the bundle does not re-enroll an existing Droplet. A normal `up` that reuses that Droplet also does not consume the replacement key. The replacement is used only after `down` removes the disposable host and a later `up` creates a fresh host. The retained `/opt/data` volume is reused during that cold rebuild.

Rotate the bundle before the next enrollment when a reusable key is approaching expiry. Revoke the old key after replacement when it should no longer authorize future hosts.

## Publication and failure safety

Before replacing the bundle, `agentctl`:

1. Refuses a symlink or non-regular target.
2. Validates and locally decrypts the existing strict bundle.
3. Copies only encrypted bundle bytes to a mode-`0600` temporary file in the same directory.
4. Sends the selected replacement to `sops set --value-stdin`; it is never a process argument.
5. Revalidates partial encryption, schema, local decryption, the selected value, and every unselected public and encrypted value.
6. Confirms the original did not change concurrently, then atomically replaces it with the complete mode-`0600` result.

A validation, SOPS, or publication failure leaves the original bundle unchanged and removes the temporary file. Keep the private age identity available locally; rotation cannot proceed if SOPS cannot decrypt and re-encrypt the selected bundle.

Verify the redacted result and local prerequisites without exposing a credential:

```bash
agentctl agent inspect --file "$bundle"
agentctl agent doctor --file "$bundle"
```

`inspect` reports only `configured`, `generated`, or `missing`. There is no `agentctl` command for printing or exporting decrypted bundle credentials. Use SOPS directly only for unsupported edits, protect the age identity and terminal session, and preserve encryption of only the `secrets` subtree.
