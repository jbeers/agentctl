# Check layered agent health

`agent status` reports whether the infrastructure and Hermes runtime described by one explicit bundle are usable:

```bash
agentctl agent status --file agents/sample-agent.agent.yml
```

The command is read-only. It does not create, attach, restart, delete, or otherwise reconcile resources. Checks stop at the first failed dependency while every later layer remains visible as `not checked`.

Status inspects these layers in order:

1. Exact-name DigitalOcean Droplet identity and provider status.
2. Exact working volume, configured region and size, and attachment to that Droplet.
3. OpenSSH reachability over the effective Tailscale MagicDNS hostname and host-side Tailscale health.
4. Rootless Hermes container state.
5. Hermes gateway health on port `8642` through the host's Tailscale address.
6. Dashboard health on port `9119` through the host's Tailscale address.

The summary state is:

- `ready` — every layer is healthy.
- `provisioning` — DigitalOcean still reports a newly provisioning Droplet.
- `absent` — no exact-name Droplet exists; SSH and runtime checks are skipped.
- `unhealthy` — compute is inactive or another checked layer failed.

Exit status is `0` only for `ready`. `absent`, `provisioning`, `unhealthy`, provider failures, and invalid local configuration return nonzero. A provider API failure is reported as indeterminate rather than being mistaken for an absent agent.

## JSON automation contract

Request one JSON document on standard output explicitly:

```bash
agentctl agent status \
  --file agents/sample-agent.agent.yml \
  --json
```

Text remains the default. `--json` and `--verbose` are deliberately incompatible; combining them fails before status checks with `agent status does not allow '--verbose' with '--json'` rather than corrupting a document.

A ready result has this shape; values are synthetic:

```json
{
  "schemaVersion": 1,
  "agent": {
    "name": "sample-agent",
    "hostname": "sample-agent"
  },
  "state": "ready",
  "ready": true,
  "layers": [
    { "name": "configuration", "state": "ready", "detail": "valid" },
    { "name": "compute", "state": "ready", "detail": "active" },
    { "name": "volume", "state": "ready", "detail": "attached" },
    { "name": "access", "state": "ready", "detail": "reachable" },
    { "name": "container", "state": "ready", "detail": "running" },
    { "name": "gateway", "state": "ready", "detail": "healthy" },
    { "name": "dashboard", "state": "ready", "detail": "healthy" }
  ]
}
```

The version 1 contract for the current `0.x` application major line is:

| Field | Type | Allowed behavior |
| --- | --- | --- |
| `schemaVersion` | number | Exactly `1`. An incompatible future shape must use a different number. |
| `agent.name` | string | Effective bundle agent name; empty only when local bundle validation prevents identity resolution. |
| `agent.hostname` | string | Effective private Tailscale hostname; empty under the same invalid-local condition. |
| `state` | string | `ready`, `absent`, `provisioning`, `unhealthy`, or `indeterminate`. |
| `ready` | boolean | `true` only when `state` is `ready`. |
| `layers` | array | Always ordered as `configuration`, `compute`, `volume`, `access`, `container`, `gateway`, `dashboard`. |
| `layers[].name` | string | One of those seven names, appearing exactly once. |
| `layers[].state` | string | `ready`, `absent`, `provisioning`, `unhealthy`, `not_checked`, or `indeterminate`. |
| `layers[].detail` | string | A stable safe product reason from the table below. |

Layer details are deliberately narrow:

| Layer | Detail values |
| --- | --- |
| `configuration` | `valid`, `invalid_local_configuration` |
| `compute` | `not_checked`, `absent`, `new`, `active`, `inactive`, `provider_failure` |
| `volume` | `not_checked`, `missing`, `configuration_mismatch`, `detached`, `attached_elsewhere`, `attached` |
| `access` | `not_checked`, `local_ssh_unavailable`, `local_ssh_keygen_unavailable`, `bundle_ssh_credential_missing`, `invalid_ssh_credential`, `host_key_mismatch`, `ssh_timeout`, `ssh_unreachable`, `tailscale_unhealthy`, `reachable` |
| `container` | `not_checked`, `unavailable`, `unknown`, `created`, `configured`, `restarting`, `running`, `removing`, `paused`, `exited`, `dead`, `stopping` |
| `gateway`, `dashboard` | `not_checked`, `healthy`, `unhealthy` |

Expected non-ready outcomes still write valid JSON to stdout and return exit `1`. A provider or invalid-local failure also writes an indeterminate document to stdout; its focused, secret-safe process diagnostic goes separately to stderr. Raw provider IDs/objects, public IPv4, command stderr, private-key paths, credentials, payloads, environment content, and endpoint bodies are never JSON fields.

A standard-library consumer can preserve the status exit code without scraping text:

```bash
status_code=0
status_json=$(agentctl agent status --file agents/sample-agent.agent.yml --json) || status_code=$?
printf '%s' "$status_json" | python3 -c '
import json, sys
status = json.load(sys.stdin)
print(status["state"])
for layer in status["layers"]:
    if layer["state"] not in ("ready", "not_checked"):
        print("{}: {}".format(layer["name"], layer["detail"]))
'
printf 'agentctl exit: %s\n' "$status_code"
```

Status uses strict existing-host-key verification and never removes or replaces a known-host entry. A mismatch is an access-health failure with guidance to run `agent up`, where exact-name reconciliation owns disposable-host key replacement. The bundle SSH identity uses the same temporary mode-`0600`, validated, cleanup-safe path as other SSH-dependent commands.

No public IPv4 address is queried or used for health checks. Provider and remote command output is reduced to safe layer states; decrypted values, environment files, payloads, and private keys are never shown. Repository checkout, branch, and Git readiness remain Hermes-owned and are explicitly outside infrastructure status.

Use the same intentional temporary hostname override supported by other access commands when needed:

```bash
agentctl agent status \
  --file agents/sample-agent.agent.yml \
  --hostname sample-agent-1 \
  --verbose
```
