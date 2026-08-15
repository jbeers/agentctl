# Cloud Agent Coder v2 Product and Behavior Specification

- **Status:** Draft
- **Audience:** Operator and implementers
- **Scope:** The next user-facing version of the existing prototype

## Problem Statement

Cloud Agent Coder has proven that a disposable DigitalOcean VM can safely run a persistent Hermes coding agent behind Tailscale. The prototype can create and reconcile a Droplet, retain Hermes state on a Block Storage volume, launch Hermes under rootless Podman, expose its dashboard privately, provide SSH access, and delete compute without deleting state.

The current interface exposes too much of that implementation. One agent file mixes cloud-account choices, host bootstrap details, SSH identity, Hermes settings, secrets, retry tuning, and persistent-state policy. Values may come from several precedence layers and implicit file discovery. Whole-file SOPS encryption makes non-secret intent difficult to read. Lifecycle names also obscure behavior: `create` reconciles existing infrastructure, while `destroy` retains the persistent volume.

An operator should not need to understand the provisioning implementation to answer:

- What will be created?
- Which values are defaults, and where did they come from?
- Which credentials leave the operator machine?
- What survives when compute is removed?
- Is Hermes ready to work?
- Can Hermes write to its workspace and run Compose integration stacks?

## Solution

V2 presents Cloud Agent Coder as an opinionated Hermes appliance rather than a generic cloud framework.

The normal input is one readable, versioned agent bundle. Non-secret intent remains plaintext; only the dedicated secret subtree is encrypted with SOPS and age. The operator passes that bundle explicitly. A redacted inspection command shows every effective value, its source, derived resource names, and persistence behavior before any cloud mutation.

The product has six concepts:

1. **Operator trust roots** — provider authentication, Tailscale membership, and the age identity remain outside the bundle.
2. **Agent bundle** — portable agent-scoped intent and encrypted credentials.
3. **Disposable compute** — a replaceable VM that carries no provider control credential.
4. **Access** — OpenSSH over Tailscale for provisioning, repair, and an interactive shell.
5. **Hermes state** — durable data mounted at `/opt/data` in Hermes.
6. **Workspace** — disposable project space mounted at `/workdir`; Hermes owns Git and project operations.

The VM host is a small substrate: Ubuntu, Tailscale, SSH, a persistent-state mount, and rootless Podman. The Hermes image supplies the coding runtime and a Compose-compatible client. Hermes controls sibling project containers through the host's rootless Podman socket; it does not run a nested daemon.

The primary lifecycle is `init`, `inspect`, `doctor`, `up`, `status`, `open`, `ssh`, and `down`. `up` creates or reconciles compute. `down` safely removes compute while retaining durable state. A fresh `up` may optionally restore a Hermes state tar archive and seed a workspace tar archive before Hermes starts.

## User Stories

### Bundle and configuration

1. As an operator, I want to initialize one agent bundle, so that an agent can be reproduced without assembling several configuration files.
2. As an operator, I want non-secret settings to remain readable without decryption, so that the bundle documents the agent's intent.
3. As an operator, I want agent-scoped credentials encrypted to age recipients, so that the bundle can be stored or transferred safely.
4. As an authorized recipient, I want to use a copied bundle with my age identity, provider login, and Tailscale identity, so that per-agent environment setup is unnecessary.
5. As an operator, I want to select the bundle explicitly, so that current-directory discovery does not choose an agent unexpectedly.
6. As an operator, I want a redacted view of effective configuration and value sources, so that defaults are convenient rather than magical.
7. As an operator, I want derived names and retention behavior shown before mutation, so that I know which Droplet, volume, hostname, and image will be used.
8. As an operator, I want unknown keys and unsupported versions rejected, so that configuration mistakes cannot silently change infrastructure.
9. As an operator, I want a doctor command to validate local tools, authentication, files, and decryption, so that predictable failures happen before cloud resources are created.
10. As an operator, I want normal operation to avoid project-specific environment variables, so that the bundle is the clear source of agent intent.

### Initialization and secrets

11. As an operator, I want initialization to generate a dedicated SSH identity, so that I do not need to register and locate a separate provider-account key manually.
12. As an operator, I want generated private keys and Hermes credentials to enter SOPS through standard input, so that they never appear in process arguments.
13. As an operator, I want initialization to refuse overwriting an existing bundle, so that credentials cannot be destroyed accidentally.
14. As an operator, I want secret values redacted from normal and verbose output, so that troubleshooting is safe to record.
15. As an operator, I want provider credentials and my age private identity to remain outside the bundle, so that distributing an agent does not distribute account-wide authority.
16. As an operator, I want a GHCR pull credential used only by the host container runtime, so that it is not exposed to Hermes or project containers.
17. As an operator, I want Hermes credentials delivered only to Hermes state, so that sibling project containers do not inherit them automatically.
18. As an operator, I want initial Hermes values distinguished from launcher-owned settings, so that seed-once and reconcile-every-up behavior are explicit.

### Bring-up and host contract

19. As an operator, I want `up` to create a missing agent, so that one command produces a usable private coding machine.
20. As an operator, I want `up` to reconcile an existing exact-name agent, so that rerunning it is safe and useful.
21. As an operator, I want a successful `up` to mean storage is ready, SSH is reachable, and Hermes health checks pass, so that success has one clear meaning.
22. As an operator, I want the host to contain only the supported substrate, so that VM behavior remains reproducible across rebuilds.
23. As an operator, I want host setup split into enrollment and runtime reconciliation, so that bootstrap credentials and long-lived runtime credentials have different delivery paths.
24. As an operator, I want no normal user-supplied root script, so that an agent bundle remains inspectable, portable, and rerunnable.
25. As an operator, I want the runtime image pinned explicitly, so that replacing a VM does not silently change Hermes behavior.
26. As an operator, I want a short-lived Tailscale enrollment credential consumed during host enrollment, so that normal access remains private without retaining the bootstrap key as host configuration.
27. As an operator, I want a deny-inbound cloud firewall reconciled automatically, so that public interfaces do not expose SSH, Hermes, or project services.
28. As an operator, I want temporary cloud-init, payload, and SSH files removed after success and failure, so that decrypted material is not left behind.

### Hermes runtime and project containers

29. As a Hermes user, I want `/workdir` writable through terminal, file, and patch tools, so that Hermes can perform normal coding work.
30. As a Hermes user, I want gateway tasks to start in `/workdir`, so that relative paths target the project workspace.
31. As a Hermes user, I want `/workdir` to have the same absolute path on the host and in Hermes, so that Compose bind mounts resolve correctly through the host daemon.
32. As a Hermes user, I want a Compose-compatible command in the runtime image, so that existing integration stacks run without project-specific host setup.
33. As a Hermes user, I want to build and run sibling containers through a rootless host socket, so that integration tests do not require Docker-in-Docker or host root.
34. As a Hermes user, I want to reach sibling published ports through `host.containers.internal`, so that separate container network namespaces are understandable.
35. As an operator, I want to reach published services through Tailscale MagicDNS, so that they remain private and use stable names.
36. As an operator, I want ordinary Compose named volumes to remain disposable, so that integration-test data does not silently become durable agent state.

### Git and workspace ownership

37. As a Hermes user, I want Hermes to own cloning, branching, committing, pushing, and repository credentials, so that `agentctl` does not duplicate Git behavior.
38. As an operator, I want no repository schema in the agent bundle, so that infrastructure readiness is independent of a particular checkout.
39. As an operator, I want Hermes readiness to mean the agent runtime is healthy rather than a repository is cloned, so that lifecycle status remains deterministic.
40. As an operator, I want `/workdir` documented as disposable, so that unpushed work is never mistaken for persisted state.

### Archive recovery and seeding

41. As an operator, I want `up` to accept a local Hermes state tar archive, so that I can recover `/opt/data` onto fresh storage.
42. As an operator, I want `up` to accept a local workspace tar archive, so that I can recover or seed `/workdir` before Hermes starts.
43. As an operator, I want to provide both archives in one `up`, so that state and workspace recovery is one deterministic operation.
44. As an operator, I want archives extracted only into empty targets, so that recovery cannot merge with unknown live state.
45. As an operator, I want unsafe archive paths and special entries rejected before extraction, so that a tar file cannot escape its target or create host devices.
46. As an operator, I want archive contents treated as secret-bearing payloads, so that paths and contents do not leak into logs or process arguments.
47. As an operator, I want restored Hermes configuration to take precedence over initial seed values, so that recovery does not silently reset the agent.
48. As an operator, I want ownership normalized after extraction, so that rootless Hermes can use restored files regardless of archive owner IDs.
49. As an operator, I want temporary local and remote archive copies deleted on every exit path, so that recovery artifacts do not accumulate.

### Access and operation

50. As an operator, I want `ssh` to use the bundle's encrypted identity through a temporary mode-`0600` file, so that direct repair access requires no separate key configuration.
51. As an operator, I want SSH to target the Tailscale hostname, so that routine administration never depends on the public IPv4 address.
52. As an operator, I want disposable server host-key replacement to happen only in a verified bring-up flow, so that convenience does not silently disable host identity checks everywhere.
53. As an operator, I want `open` to launch the private Hermes dashboard, so that the bundle's effective hostname is reused consistently.
54. As an operator, I want `status` to distinguish absent, provisioning, ready, and unhealthy agents, so that cloud existence is not confused with Hermes readiness.
55. As an operator, I want status failures to identify the failed layer without revealing secrets, so that recovery starts at the right boundary.

### Safe removal

56. As an operator, I want `down` to succeed harmlessly when compute is absent, so that cleanup is idempotent.
57. As an operator, I want `down` to stop Hermes and flush writes before unmounting state, so that retained state is consistent.
58. As an operator, I want deletion blocked when persistent state cannot be prepared safely, so that compute savings cannot silently cause data loss.
59. As an operator, I want the Droplet deleted while its provider volume remains, so that compute billing stops without deleting Hermes state.
60. As an operator, I want `down` to state that `/workdir` will be discarded and that `agentctl` does not manage Git, so that responsibility is explicit.
61. As an operator, I want Tailscale logout attempted without making an otherwise safe deletion depend on it, so that stale ephemeral nodes do not prevent cleanup.
62. As an operator, I want infrastructure lifecycle code free of hardcoded Telegram behavior, so that messaging remains a Hermes or future control-plane concern.

### Verification

63. As an implementer, I want command construction and parsing tested without live cloud access, so that most changes are fast and deterministic.
64. As an implementer, I want generated remote scripts syntax-checked, so that quoting errors fail locally.
65. As an implementer, I want archive extraction tested against traversal, symlink, ownership, and non-empty-target cases, so that recovery is safe at its trust boundary.
66. As an implementer, I want secret-handling tests to assert absence from arguments and output, so that regressions are visible.
67. As an operator, I want a deliberate cold-rebuild verification against a disposable test agent, so that mocks do not become the only evidence that provisioning works.
68. As an operator, I want live verification to prove public ingress remains blocked while Tailscale access and Compose workflows work, so that the security model is tested end to end.

## Implementation Decisions

### Product boundary

- V2 is explicitly a Hermes coding-agent appliance. Supporting unrelated agent runtimes is deferred.
- DigitalOcean remains the only compute provider in this version.
- Ubuntu 24.04 on `linux/amd64` is the supported host contract.
- The current provisioning, teardown, and secret-handling implementation is reused and reshaped; V2 is not a greenfield rewrite.

### Agent bundle

- The bundle has version 2 and a small public surface for identity, compute, state, access, runtime image, initial Hermes settings, and secrets.
- SOPS encrypts only the dedicated secret subtree. Structural keys and non-secret intent remain readable.
- Explicit bundle selection is the canonical workflow. Automatic current-directory selection is not part of the V2 contract.
- Normal precedence is per-command CLI input over bundle values over visible built-in defaults. Broad lifecycle environment overrides are not part of the normal V2 interface.
- Provider authentication continues through the provider's standard credential mechanism. SOPS/age and Tailscale use their standard local identities.
- `inspect` uses the same resolver as mutating commands and displays redacted values, sources, derived resource names, archive intent, and retention semantics.

### Access

- `init` generates one agent-scoped Ed25519 identity. The private key is encrypted in the bundle and materialized only as a mode-`0600` temporary file for SSH-dependent operations.
- The corresponding public key is derived and installed during host enrollment without requiring the operator to select an existing DigitalOcean account key.
- OpenSSH over Tailscale is the V2 access transport. Tailscale SSH is deferred.
- Routine commands use the MagicDNS hostname. Public IPv4 is never the normal access path.
- Host-key replacement is limited to the exact disposable host being reconciled and is not a global SSH policy.

### Host and runtime boundary

- Host enrollment installs and configures only access, Tailscale, the unprivileged `agent` account, and rootless Podman.
- Runtime reconciliation prepares storage, logs the host runtime into a private registry when needed, pulls the selected image, reconciles launcher-owned settings, and starts Hermes.
- Users customize Hermes through the runtime image and project behavior through repository files and Compose. V2 exposes no arbitrary host bootstrap hook.
- Provider tokens and age identities never leave the operator machine. The Tailscale enrollment credential is limited to bootstrap. Registry pull credentials go only to host Podman. Hermes initial settings go only to Hermes state.

### Filesystem and containers

- Host `/agent-dirs/<agent-name>` is mounted at Hermes `/opt/data` and contains durable Hermes state.
- Host `/workdir` is mounted at Hermes `/workdir` and is disposable.
- Launcher-owned Hermes settings include a local terminal backend rooted at `/workdir`, container working directory `/workdir`, and safe write roots `/opt/data` plus `/workdir`.
- Hermes receives the rootless Podman socket and a Compose-compatible client. Sibling containers do not inherit Hermes credentials automatically.
- Hermes and sibling containers retain separate network namespaces. Hermes reaches host-published sibling ports through `host.containers.internal`.

### State and archives

- V2 makes the current working-state strategy explicit as a provider volume. Additional working-storage and checkpoint providers are deferred.
- The provider volume remains authoritative after initial creation and survives `down`.
- `up` accepts separate state and workspace tar archives. Archive paths are local CLI inputs and are never stored as persistent bundle configuration.
- Archive entries are relative to their destination root. Extraction occurs only into empty destinations before Hermes starts.
- Extraction rejects absolute paths, parent traversal, unsafe link targets, device nodes, and other entries that can escape or alter the host outside the destination.
- State restoration precedes initial Hermes seeding. Existing restored `.env` and configuration remain authoritative.
- Workspace archives are inputs to a disposable workspace; after start, Hermes owns all Git and project behavior.

### Lifecycle semantics

- `up` means create or reconcile. Its success condition includes provider resources, storage, SSH readiness, and Hermes health.
- `status` reports each meaningful layer rather than only Droplet existence.
- `down` stops Hermes, flushes writes, unmounts state, schedules best-effort Tailscale logout, and deletes only compute.
- `down` never commits, pushes, or otherwise interprets a repository. Automated idle deletion remains deferred until Hermes offers a machine-verifiable shutdown checkpoint.
- Hardcoded Telegram readiness and shutdown sends are removed from infrastructure lifecycle behavior.
- A state-destroying `purge` operation is not included in V2.

### Deep, testable modules

The implementation should preserve a small number of meaningful boundaries rather than introduce a generic plugin framework:

- **Bundle resolver:** selection, in-memory decryption, schema validation, defaults, source tracking, and redacted inspection.
- **Lifecycle orchestrator:** user-visible `up`, status, access, and `down` behavior.
- **Host reconciler:** validated remote enrollment and runtime scripts with no secret-bearing shell interpolation.
- **Archive seeder:** format validation and extraction into a designated empty root.
- **Command runner:** argv-based local process execution and secret-safe standard input.

A second provider or storage implementation may justify extracting a provider interface later. V2 should not create one preemptively.

## Testing Decisions

- Tests assert externally observable behavior: parsed commands, resolved plans, process argv, output, exit status, resource safety, and resulting archive trees. They do not lock tests to private helper structure.
- The bundle resolver is tested with plaintext, partially SOPS-encrypted, malformed, ambiguous, and unknown-key fixtures. Tests assert that inspection never emits decrypted values.
- Initialization is tested for exclusive creation, restrictive permissions, random generated credentials, generated SSH identity, standard-input secret injection, and cleanup after failure.
- Lifecycle orchestration continues to use a fake command runner for deterministic provider, SSH, SCP, browser, and SOPS behavior.
- Generated host scripts are syntax-checked with Bash and tested with validated arguments. Secret payloads are never included in assertion failure text.
- Archive tests use small generated tar files and cover valid restoration, both archives together, non-empty targets, absolute paths, parent traversal, link escape, special files, ownership normalization, and cleanup after failure.
- Runtime tests verify the launcher supplies both safe-write roots, sets `/workdir` as Hermes' terminal and process working directory, and exposes the rootless socket without host root privilege.
- A minimal Compose fixture verifies a sibling bind mount can read a known `/workdir` file and a published health endpoint is reachable from Hermes.
- Static verification includes Bash syntax, the existing TestBox suite, the native build, and whitespace checks.
- Live cold-rebuild verification is a separate human-approved step because it creates billable resources and may touch real Tailscale and provider state.

## Out of Scope

- Hermes-managed repository cloning, branching, committing, or pushing in `agentctl`
- Automatic shutdown based on idleness
- A permanent NAS control-plane daemon or lifecycle API
- Additional compute providers
- External secret stores beyond embedded SOPS/age secrets
- Backup/checkpoint providers such as Restic, SFTP, S3, or NAS synchronization
- Live NFS/SMB-backed Hermes state
- Periodic backup services
- Tailscale SSH
- Multi-user access control or per-user SSH auditing
- Public ingress or public service publishing
- Arbitrary user-provided host scripts
- Generic runtime plugins or non-Hermes agent images
- Destructive persistent-state purge
- Automatic migration of every prototype configuration field
- Persistence of Compose named volumes
- Automatic workspace backup or Git safety checks

## Further Notes

- A portable bundle is not self-authorizing. A recipient still needs an approved age identity, access to the same provider account or equivalent resources, and membership in the tailnet.
- State and workspace tar files may contain credentials or uncommitted source. Operators must protect them as secret-bearing files.
- The existing DigitalOcean volume is durable working storage, not an independent backup. A later checkpoint-store design should remain separate from the working-storage choice.
- If local disposable storage plus a NAS checkpoint becomes the only durable copy, that NAS repository is primary persistence rather than merely a backup.
- V2 deliberately fixes current implementation-specific workspace behavior: the official Hermes image defaults its safe write root to `/opt/data`, so the launcher must add `/workdir` and reconcile Hermes' terminal working directory.
- The roadmap is maintained as local issue documents under `v2/issues/`. This PRD is the behavioral source of truth; issue ordering may change without changing the product contract.
