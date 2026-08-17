# Create your first agent

This walkthrough starts with the published Linux executable and public runtime. It uses no source checkout, BoxLang toolchain, private container registry, or registry token.

Complete [Prerequisites](prerequisites.md) first. Before using real projects or credentials, review the [Security model](security.md) and [Project status and limitations](project-status.md). Commands use the synthetic agent name `agentctl-tutorial`; choose another valid lowercase name if that exact Droplet or volume already exists in your account.

## Install the released executable

Follow [Install agentctl](install.md), including checksum verification. Confirm the exact supported release:

```bash
agentctl --version
```

## Choose local paths

Keep bundles outside project checkouts:

```bash
agent_name=agentctl-tutorial
region=nyc3
bundle_dir="$HOME/.config/agentctl/agents"
bundle="$bundle_dir/$agent_name.agent.yml"
install -d -m 0700 "$bundle_dir"
test ! -e "$bundle"
```

Lifecycle commands never scan the current directory. Keep using this explicit `--file "$bundle"` selection.

## Initialize the encrypted bundle

Read the public age recipient from the protected local identity:

```bash
recipient=$(age-keygen -y "$HOME/.config/sops/age/keys.txt")
```

Initialize with built-in public defaults:

```bash
agentctl agent init \
  --name "$agent_name" \
  --file "$bundle" \
  --age-recipient "$recipient"
```

The command asks through hidden, confirmed prompts for:

1. The reusable ephemeral Tailscale enrollment key.
2. A new Hermes dashboard password.
3. An optional registry pull token.

Leave the registry token blank. The supported `ghcr.io/jbeers/agentctl` runtime is public and pulls anonymously.

`init` validates SOPS encryption and local age decryption before asking for credentials. It generates a dedicated SSH identity and Hermes keys, encrypts only `secrets`, publishes the bundle with mode `0600`, and removes temporary files. Do not paste a prompted value into the shell command, a YAML editor, or chat.

## Inspect the redacted plan

Inspection changes no file or infrastructure:

```bash
agentctl agent inspect --file "$bundle"
```

Confirm the output shows:

- Agent and Tailscale hostname `agentctl-tutorial`
- Droplet size `s-4vcpu-8gb` in `nyc3`
- Volume `agent-home-agentctl-tutorial` at 10 GiB
- The public digest-pinned `ghcr.io/jbeers/agentctl` runtime recorded by initialization
- Required secrets as `configured` or `generated`, never their values
- `/opt/data` retained and `/workdir` discarded by `down`

Stop if the identity or effective resource plan is not what you intend. Never share the bundle, SOPS ciphertext, private hostname, or verbose output as a support shortcut.

## Run read-only diagnostics

```bash
agentctl agent doctor --file "$bundle"
```

Doctor checks local commands, bundle decryption, the generated SSH key, browser launcher, and `doctl account get`. It creates no provider resource. Resolve every reported prerequisite, bundle, or provider-authentication failure before continuing.

## Cost gate

The next command can create a billable `s-4vcpu-8gb` Droplet and 10 GiB Block Storage volume. Review current [Droplet pricing](https://www.digitalocean.com/pricing/droplets) and [Block Storage pricing](https://www.digitalocean.com/pricing/volumes).

`down` later deletes the Droplet and **does not delete the volume**. Do not run `up` unless you plan to complete [all cleanup steps](#complete-cost-and-identity-cleanup).

## Bring up the agent

```bash
agentctl agent up --file "$bundle"
```

First bring-up can take several minutes while DigitalOcean creates the resources, Ubuntu installs host prerequisites, the host joins Tailscale, the public runtime pulls, and Hermes becomes healthy. Success means private SSH, gateway health, and the in-container Compose client all passed.

Do not manually repair the VM if `up` fails. Use the focused stage error and [Troubleshooting](troubleshooting.md), fix the automation or prerequisite, and rerun the same explicit command. Exact-name resources are reconciled rather than duplicated.

## Check every readiness layer

```bash
agentctl agent status --file "$bundle"
```

A usable agent reports summary `ready` and healthy compute, volume, Tailscale/SSH, container, gateway, and dashboard layers. Exit status is zero only for `ready`.

Status is read-only. An `absent`, `provisioning`, or `unhealthy` result is not success and later layers may show `not checked` when an earlier dependency failed.

## Open the private dashboard

```bash
agentctl agent open --file "$bundle"
```

Sign in as `admin` with the dashboard password entered during initialization. The URL is plain HTTP on port 9119, but it is routed through Tailscale's encrypted network and is not exposed by the public DigitalOcean firewall. Do not replace this private route with public ingress.

If the browser does not open, follow the dashboard and Tailscale checks in [Troubleshooting](troubleshooting.md).

## Configure a Hermes model provider

A healthy appliance still needs a model-provider account. In the Hermes dashboard:

1. Open **Keys**.
2. Choose one provider supported by [Hermes](https://hermes-agent.nousresearch.com/docs/integrations/providers), such as OpenRouter, Anthropic, or OpenAI.
3. Set only that provider's API key using the dashboard secret field.
4. Open **Models**, select the same provider and one model available to the account, and save the selection.
5. Start a new chat and ask for a short response to prove inference works.

Use a provider credential with spending controls and the least authority practical for this agent. Never put it in the agent bundle, cloud-init, a chat message, a project file, or a Compose environment. Hermes stores this configuration under retained `/opt/data`, so it survives `down` and a cold rebuild with the same volume.

Provider signup, billing, model availability, and rate limits remain provider responsibilities. A failed inference request does not mean the infrastructure status layers are unhealthy.

## Configure persistent, scoped GitHub access

Skip this section if the agent needs no private GitHub repository. Otherwise, create a fine-grained GitHub personal access token limited to the selected repository and only the permissions the agent needs. For ordinary clone/pull/push work, start with repository **Contents** access; add pull-request or issue permissions only for an explicit task.

In the private Hermes dashboard:

1. Open **Keys**.
2. Find `GITHUB_TOKEN`, choose **Set**, and save the token in that secret field.
3. Start a new chat so its credential scope includes the newly stored key.
4. Ask Hermes to use its GitHub authentication skill to check authentication, configure the Git credential helper, and view one repository selected by the token.

Use a request such as:

```text
Use the GitHub authentication skill to verify access without printing any credential or environment variable. Check GitHub CLI authentication, configure the Git credential helper, and view OWNER/REPOSITORY. Report only whether each check succeeded.
```

The GitHub skill owns secret-safe access and invokes `gh` or `git` through the terminal when appropriate. Hermes strips managed secrets from arbitrary terminal subprocess environments; do not ask it to print, export, or manually recover `GITHUB_TOKEN`.

The token and Git integration are stored under retained `/opt/data`, so they survive a cold rebuild with the same volume. They are not placed in cloud-init, the agent bundle, `/workdir`, lifecycle output, or sibling containers by default.

A later GitHub task can clone the selected repository into disposable workspace storage:

```text
Use the GitHub repository skill to clone OWNER/REPOSITORY into /workdir/project.
```

`OWNER/REPOSITORY` is a synthetic placeholder for the deliberately selected repository, not a credential. Commit and push valuable changes before `down`; persistent authentication does not make a checkout under `/workdir` persistent.

## Run the first Hermes task

Start a new dashboard chat and send the following synthetic task. It deliberately asks Hermes to exercise terminal, file, patch, and rootless Compose behavior only under `/workdir`:

```text
Work only in /workdir/agentctl-first-task.

1. Use the terminal tool to create that directory and initialize a Git repository.
2. Use the file-writing tool, not shell redirection, to create known.txt containing exactly:
   pending
3. Use the patch tool to replace "pending" with "agentctl-compose-ok".
4. Use the file-writing tool to create compose.yaml with this content:

services:
  workspace-probe:
    image: docker.io/library/busybox@sha256:b7f3d86d6e84fc17718c48bcde1450807faa2d56704205c697b4bd5df7b9e29f
    working_dir: /workspace
    security_opt:
      - label=disable
    command: ["sh", "-c", "test \"$(cat known.txt)\" = agentctl-compose-ok && httpd -f -p 18080"]
    volumes:
      - .:/workspace:ro
    ports:
      - "18080:18080"
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "-", "http://127.0.0.1:18080/known.txt"]
      interval: 2s
      timeout: 2s
      retries: 15

5. Use the terminal tool in that directory to run:
   git add --intent-to-add known.txt compose.yaml
   podman-compose --project-name agentctl-first-task up --detach
6. Use the terminal tool to run:
   curl --fail --retry 15 --retry-delay 2 --retry-connrefused http://host.containers.internal:18080/known.txt
7. Report the exact response and `git diff -- known.txt compose.yaml`.
Do not commit, push, or work outside that directory.
```

The expected HTTP response is:

```text
agentctl-compose-ok
```

From the operator machine, prove the published service is reachable over the tailnet:

```bash
curl --fail --retry 15 --retry-delay 2 --retry-connrefused \
  "http://$agent_name:18080/known.txt"
```

The same port is not publicly reachable because the managed DigitalOcean firewall has no inbound rules.

Ask Hermes to clean up the disposable sibling service:

```text
In /workdir/agentctl-first-task, use the terminal tool to run:
podman-compose --project-name agentctl-first-task down --volumes
Then report whether all project containers and volumes were removed.
```

This task is intentionally disposable. For real work, clone into `/workdir`, use Git normally, and commit and push before deleting compute.

## Use SSH only for host repair

```bash
agentctl agent ssh --file "$bundle"
```

This opens `root@<tailscale-hostname>` with the generated per-agent key. Root has full VM authority and is intended for diagnosis or repair. Hermes itself remains the unprivileged container user connected only to the `agent` user's rootless Podman socket.

Do not install one-off fixes to make a failed tutorial pass. A clean-room failure should be fixed in `agentctl` or its documented prerequisite and then reproduced from the normal lifecycle.

## Review persistence before teardown

Before continuing:

- `/opt/data` contains retained Hermes state and may contain model/GitHub credentials.
- `/workdir`, its Git checkout, the first-task files, sibling containers, and ordinary Compose volumes belong to disposable compute.
- The DigitalOcean volume is durable working storage, not an independent backup.
- `agentctl` does not check Git status or push work for you.

See [Persistence, billing, and cleanup](persistence.md) for the complete lifecycle table.

## Take the agent down

After committing and pushing anything worth keeping, decide whether retained Hermes state needs a portable backup. Export must run while the appliance is still fully ready:

```bash
# Optional: run only when this state should be retained independently.
mkdir -p -m 0700 "$HOME/backups/agentctl"
agentctl agent export \
  --file "$bundle" \
  --output "$HOME/backups/agentctl/tutorial-state.tar"

agentctl agent down --file "$bundle"
```

`down` stops Hermes, flushes filesystems, unmounts `/opt/data`, deletes the exact Droplet, removes its local known-host entry, and retains `agent-home-agentctl-tutorial`. A stop, flush, or unmount failure blocks deletion rather than risking state.

Confirm compute is absent:

```bash
if doctl compute droplet list --format ID,Name --no-header | awk -v name="$agent_name" '$2 == name { found=1 } END { exit !found }'; then
  printf 'Droplet still exists; do not delete the volume.\n' >&2
else
  printf 'Exact-name Droplet is absent.\n'
fi
```

## Delete the retained tutorial volume

This is irreversible. Do it only for a tutorial whose retained Hermes state is no longer needed or whose optional export has been independently protected.

```bash
agentctl agent purge --file "$bundle"
```

Before prompting, purge names `agent-home-agentctl-tutorial`, warns that Hermes state will be permanently deleted, and reminds you that `agentctl` has not verified a backup. Type the exact case-sensitive agent name `agentctl-tutorial` to continue.

Purge refuses any exact-name Droplet; a duplicate, attached, replaced, wrong-region, or wrong-size volume; malformed provider data; and provider uncertainty. It repeats provider checks after confirmation and sends only the previously established exact volume ID to deletion. There is no user-facing `--force` bypass. Run the same command again to verify the clearly reported, non-prompting `already absent` result.

Read [Purge retained state](purge.md) before using this command outside the disposable tutorial.

## Complete cost and identity cleanup

1. In the Tailscale admin console, find the exact `agentctl-tutorial` machine. Confirm it is the tutorial node, then remove it if ephemeral cleanup has not already done so.
2. Revoke the tutorial's reusable auth key when no cold rebuild is planned.
3. Confirm the local host key is gone:

   ```bash
   if ssh-keygen -F "$agent_name" >/dev/null; then
     ssh-keygen -R "$agent_name"
   fi
   ```

4. Only after the Droplet and volume are accounted for, remove the tutorial bundle:

   ```bash
   rm -f "$bundle"
   ```

5. Keep the age identity if any other bundle uses it. Remove a tutorial-only identity only after confirming no retained bundle or backup depends on it.
6. Remove the verified release download directory if it is no longer needed. Removing `/usr/local/bin/agentctl` is optional and never substitutes for cloud cleanup.
7. Account for any model-provider or GitHub token created for the tutorial; revoke it if it is no longer needed.

The tutorial is complete only when the exact Droplet is absent, the retained volume is absent, the Tailscale node and enrollment key are accounted for, the known-host entry is absent, and local tutorial files are deliberately kept or removed.
