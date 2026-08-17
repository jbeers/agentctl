# Access a running agent

After `agent up` succeeds, use the bundle's effective Tailscale MagicDNS hostname for repair access and the private Hermes dashboard. Neither command contacts DigitalOcean or uses the Droplet's public IPv4 address.

## Open an SSH repair session

```bash
agentctl agent ssh --file agents/sample-agent.agent.yml
```

`ssh` opens an interactive `root@<tailscale-hostname>` OpenSSH session with terminal input and output attached directly. Root is the supported host-repair account because the agent's public key is enrolled there during `up`. Hermes itself continues to run as the unprivileged `agent` user; `agentctl` does not grant Hermes broad host `sudo` access.

The per-agent private key is decrypted from the selected bundle, written to a unique mode-`0600` temporary file, validated with `ssh-keygen`, and removed when the session exits or fails. Key material is never placed in command arguments or lifecycle output. Local `ssh`, `ssh-keygen`, bundle decryption access, tailnet membership, and MagicDNS resolution are required; `doctl` is not.

SSH accepts a previously unseen host key but refuses a changed known-host key. `agent ssh` never deletes a mismatched entry. If the disposable host was replaced, reconcile the exact agent through `agent up` with the same bundle before connecting again; that verified bring-up path is responsible for replacing the stale entry.

A hostname override is available for an intentional temporary MagicDNS collision:

```bash
agentctl agent ssh \
  --file agents/sample-agent.agent.yml \
  --hostname sample-agent-1
```

## Open the Hermes dashboard

```bash
agentctl agent open --file agents/sample-agent.agent.yml
```

`open` launches `http://<tailscale-hostname>:9119` with `xdg-open` on Linux or `open` on macOS. It does not put dashboard credentials in the URL or browser command. Sign in through the Hermes UI.

The same hostname override is supported:

```bash
agentctl agent open \
  --file agents/sample-agent.agent.yml \
  --hostname sample-agent-1
```
