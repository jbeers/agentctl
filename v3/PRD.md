# agentctl Public Product and Adoption Specification

- **Status:** Approved roadmap
- **Audience:** Operators, contributors, and implementers
- **Scope:** Turn the validated V2 appliance into an installable public project, launch a useful documentation website, and complete the most important day-two safety workflows

This roadmap is the next product workstream after the completed V2 lifecycle. It does not introduce a version 3 agent-bundle schema; existing version 2 bundles remain the product contract unless a future requirement justifies a schema change.

## Problem Statement

`agentctl` has proven its core promise: an operator can use one encrypted bundle to create a private DigitalOcean VM, attach durable Hermes state, connect through Tailscale, run Hermes and rootless Compose workloads, remove disposable compute safely, and rebuild without manual VM repair.

That proven implementation is still difficult for another developer to adopt. The executable must be built from source with a local development toolchain, the supported runtime image is not published from the canonical project, and the documented default image does not match the image used for live acceptance. The current repository has no public release automation, project license, support policy, or deployed documentation site. Existing guides explain individual commands well, but they do not provide one complete journey from installing `agentctl` through configuring Hermes, doing useful work, understanding cost and persistence, and cleaning up every billable resource.

Day-two operation also has important gaps. Bootstrap and registry credentials expire but have no safe write-only rotation workflow. State archives can be restored but cannot be exported through the same trust boundary. `down` intentionally retains durable state, but operators have no guarded `agentctl` command for deleting an unwanted detached volume. Human-readable status is strong, but stable machine-readable status is not available for later admin-agent or automation integration.

A polished website alone would advertise a source checkout rather than a usable product. Public documentation and product distribution must therefore be delivered together. The project should remain a focused Hermes appliance for DigitalOcean rather than expanding into a generic cloud framework while these fundamentals are unfinished.

## Solution

Publish `agentctl` as one coherent open-source product: project name, repository, executable, documentation site, release artifacts, and runtime image all use the `agentctl` identity.

The first public release provides a tested Linux `amd64` executable that can be downloaded without BoxLang, CommandBox, or MatchBox. Continuous integration builds with a pinned toolchain, runs the existing deterministic suite, syntax-checks generated scripts, and publishes immutable release artifacts with checksums and source revision metadata. The matching public Hermes runtime image is built from the same canonical repository, tested for its runtime contract, published with immutable identity, and selected by the visible built-in default. A public image removes the registry token from the normal first-agent journey while retaining private-image overrides for operators who need them.

A docs-first static website reuses the existing behavior-oriented Markdown. It adds installation, prerequisites, a clean-room first-agent walkthrough, first-use Hermes and GitHub configuration, security and persistence concepts, cost and cleanup guidance, troubleshooting, supported-platform information, and release documentation. The site is built in the same repository with an established static documentation generator and deployed through GitHub Pages. It has no application backend, control plane, account system, CMS, or custom documentation service.

The next day-two slices add narrow product capabilities without reopening the V2 configuration surface:

1. Prompt-only rotation of supported encrypted bundle credentials, with no secret-reading command.
2. Safe, atomic export of durable Hermes state into the archive format already accepted by `up`.
3. Explicit, guarded deletion of the exact detached provider volume after the operator confirms destructive intent.
4. Stable, redacted JSON output for layered status so external automation can consume the existing lifecycle truth.

A final operator-approved public-alpha exercise starts from published artifacts and public documentation rather than a development checkout. It proves installation, first bring-up, useful Hermes operation, credential rotation, state export and restoration, safe teardown, guarded purge, website correctness, and complete resource cleanup.

The original longer-term vision remains sequenced behind these foundations. A concrete backup destination, a machine-verifiable Hermes checkpoint contract, automatic idle shutdown, admin Hermes integration, and a second provider are considered only after the public product and day-two safety workflows are established.

## User Stories

### Public identity and project trust

1. As a prospective user, I want the product, repository, executable, website, and release artifacts to use the name `agentctl`, so that I can identify one coherent project.
2. As a prospective user, I want one canonical public source repository, so that I know where releases, documentation, issues, and security notices originate.
3. As a contributor, I want the current clean source to stand on its own without importing the old prototype, so that obsolete history and local working files cannot contaminate the public project.
4. As a prospective user, I want an explicit open-source license, so that I understand how I may use and contribute to the project.
5. As a security reporter, I want a private reporting policy and supported-version statement, so that vulnerabilities reach the maintainer responsibly.
6. As a contributor, I want concise contribution and local-verification instructions, so that I can submit a change without reverse-engineering the development workflow.
7. As a maintainer, I want releases produced from a clean canonical checkout, so that local bundles, credentials, binaries, and development artifacts cannot be published accidentally.
8. As an operator, I want release maturity and known limitations stated honestly, so that a public alpha is not mistaken for a hosted or fully automated service.

### Executable distribution

9. As an operator, I want to download a native `agentctl` executable, so that I do not need the project development toolchain to use the product.
10. As an operator, I want a published checksum for each executable, so that I can verify the downloaded bytes before installation.
11. As an operator, I want `agentctl` to report its application version and source revision, so that support conversations identify the exact build.
12. As a maintainer, I want the native compiler and dependencies pinned in release automation, so that a release can be reproduced instead of depending on one workstation checkout.
13. As a contributor, I want every proposed change to run TestBox, generated-Bash syntax checks, whitespace checks, and native compilation, so that the validated V2 behavior remains intact.
14. As an operator, I want immutable release artifacts, so that a version does not silently change after publication.
15. As an operator, I want direct installation and upgrade instructions, so that adopting a new release is deliberate and understandable.
16. As an operator, I want the initially supported operator and VM platforms stated explicitly, so that unsupported systems do not fail mysteriously.
17. As an operator, I want release notes to distinguish product changes, security changes, and required operator action, so that upgrades are predictable.
18. As a maintainer, I want each release tied to source revision metadata, so that executable and source provenance can be inspected.
19. As an existing V2 operator, I want public releases to continue reading version 2 bundles, so that project publication does not force an unrelated configuration migration.
20. As an operator removing the tool, I want uninstall instructions that distinguish the local executable from retained cloud resources, so that deleting a binary is not mistaken for stopping billing.

### Supported Hermes runtime

21. As a new operator, I want the default Hermes runtime image to be publicly pullable, so that the normal first-agent workflow does not require a GHCR token.
22. As an operator, I want the runtime selected by an immutable tag or digest, so that rebuilding a VM does not silently change Hermes behavior.
23. As an operator, I want the default runtime tested with the corresponding `agentctl` release, so that the CLI and appliance contract are compatible.
24. As a maintainer, I want the runtime image built from the canonical repository, so that its source and release process are visible.
25. As a maintainer, I want the published image smoke-tested for Hermes, the Compose client, GitHub CLI, the rootless Podman client, and `/workdir` behavior, so that a broken image is not advertised.
26. As an advanced operator, I want to retain the existing private-image override and optional registry credential, so that a public default does not remove controlled customization.
27. As a new operator, I want the built-in image default and public documentation to point to the currently supported release, so that copying the quickstart chooses tested software.
28. As an operator, I want runtime upgrade guidance to explain reconciliation and retained state, so that changing an image does not create incorrect assumptions about `/opt/data` or `/workdir`.

### Installation and first useful agent

29. As a new operator, I want one prerequisites page, so that DigitalOcean, Tailscale, SOPS, age, SSH, and browser requirements are not scattered across guides.
30. As a new operator, I want exact DigitalOcean authentication guidance, so that `doctor` can validate my provider access before billable creation.
31. As a new operator, I want guidance for creating an appropriately scoped reusable ephemeral Tailscale enrollment key, so that rebuilds work without granting unnecessary authority.
32. As a new operator, I want guidance for creating and protecting an age identity, so that I can initialize and later decrypt my bundle safely.
33. As a cost-conscious operator, I want the default compute and retained-volume billing behavior explained before `up`, so that no resource cost is surprising.
34. As a new operator, I want one walkthrough covering `init`, `inspect`, and `doctor`, so that configuration and secret failures occur before cloud mutation.
35. As a new operator, I want the walkthrough to cover `up`, layered `status`, `ssh`, `open`, and `down`, so that I understand the complete supported lifecycle.
36. As a Hermes user, I want first-use guidance for configuring a model provider after bring-up, so that a healthy VM becomes a useful coding agent.
37. As a Hermes user, I want guidance for persistent GitHub authentication inside Hermes, so that repository and GHCR permissions remain project-scoped and survive rebuilds.
38. As a Hermes user, I want a small verified first task and Compose example, so that I can prove terminal, file, patch, GitHub, and sibling-container workflows.
39. As an operator, I want the walkthrough to emphasize that `/opt/data` survives while `/workdir` does not, so that I protect code and state correctly.
40. As an operator, I want final-cleanup instructions that include retained volumes, so that completing a tutorial cannot leave indefinite monthly charges.
41. As a security-conscious user, I want a plain-language security model, so that I know which credentials leave my machine and what authority Hermes receives.
42. As a prospective user, I want a known-limitations page, so that DigitalOcean-only, Hermes-only, Linux/amd64, private-access, and manual-backup boundaries are explicit.
43. As an operator facing a failure, I want troubleshooting organized by the same layers and focused errors reported by the CLI, so that I start recovery at the correct boundary.
44. As a documentation reader, I want responsive navigation and built-in search, so that command and recovery guidance is usable from normal desktop and mobile browsers.
45. As a prospective user, I want one canonical documentation URL, so that README links and search results do not point to stale instructions.
46. As a prospective user, I want a sanitized lifecycle demonstration, so that I can understand the product without exposing a real credential or account resource.
47. As an operator, I want documentation built and checked with each release, so that examples and supported defaults match the downloadable executable.
48. As a maintainer, I want examples and recordings to use synthetic values, so that public documentation can never depend on redacting real secrets after capture.

### Credential rotation

49. As an operator, I want to replace an expired Tailscale enrollment key in an existing bundle, so that a future cold rebuild can enroll successfully.
50. As an operator, I want to replace or remove a registry pull token, so that image access can be rotated without recreating agent identity and Hermes state.
51. As an operator, I want to rotate the dashboard password, so that user-facing access credentials can change without editing encrypted YAML manually.
52. As an operator, I want replacement values entered through hidden confirmed prompts and SOPS standard input, so that rotation cannot expose credentials in arguments or plaintext files.
53. As a security-conscious operator, I want no command that prints decrypted bundle secrets, so that rotation does not add a credential-exfiltration interface.
54. As an operator, I want rotation to validate encryption, decryption, schema, and atomic publication before replacing the bundle, so that a failed update cannot destroy a working configuration.

### Portable state and destructive cleanup

55. As an operator, I want to export durable Hermes state into a local tar archive, so that the existing restore path has a matching backup source.
56. As an operator, I want Hermes quiesced and filesystem writes flushed before export, so that the archive represents a consistent state boundary.
57. As an operator, I want the exported archive published atomically with mode `0600`, so that partial or world-readable secret-bearing backups are never presented as successful.
58. As an operator, I want archive paths and contents omitted from normal output, so that recording a backup command does not disclose private state.
59. As an operator, I want exported bytes accepted by the existing state-archive validator and restore flow, so that backup and recovery use one format contract.
60. As an operator, I want export failures to clean temporary files and restore the prior running state when safe, so that attempting a backup does not strand a healthy agent unnecessarily.
61. As an operator, I want to delete an unwanted retained provider volume through `agentctl`, so that complete billing cleanup does not require an undocumented provider command.
62. As an operator, I want purge to require explicit typed confirmation naming the agent, so that ordinary lifecycle commands cannot destroy state accidentally.
63. As an operator, I want purge to refuse duplicate, attached, mismatched, or indeterminate volumes, so that only the exact known detached state resource can be deleted.
64. As an operator, I want purge output to state that the operation is irreversible and report the exact deleted resource identity, so that destructive cleanup is auditable.

### Automation-ready status

65. As an automation author, I want layered status available as JSON, so that I do not need to scrape human-formatted text.
66. As an automation author, I want a documented stable schema and the same ready/non-ready exit semantics, so that integrations behave predictably.
67. As a security-conscious operator, I want JSON output to preserve all existing redaction and private-route boundaries, so that automation does not become a secret-leak path.
68. As a human operator, I want existing text output to remain the default, so that machine output does not make interactive use worse.
69. As a future admin-agent integrator, I want status JSON to expose dependency-layer states rather than provider payloads, so that automation consumes product semantics rather than DigitalOcean internals.

### Public-alpha verification

70. As a prospective user, I want a clean system to install the published binary using only public instructions, so that maintainer workstation state is not an undocumented prerequisite.
71. As a new operator, I want the default public runtime to pull without private registry credentials, so that the advertised quickstart is complete.
72. As an operator, I want published artifacts to complete the full private lifecycle and useful Hermes workflow, so that source-build acceptance is not the only evidence.
73. As an operator, I want a rotated bootstrap credential to work in a subsequent cold rebuild, so that the day-two credential workflow is proven.
74. As an operator, I want exported state restored to a fresh test target, so that backup portability is proven end to end.
75. As an operator, I want guarded purge proven only after separate destructive approval, so that complete cleanup is verified without weakening data-loss safeguards.
76. As a documentation reader, I want every site link, command example, release URL, and supported default checked before launch, so that the website is a reliable product entry point.
77. As a maintainer, I want the public-alpha exercise to end with no exact-name Droplets, volumes, Tailscale nodes, known-host entries, credentials, or temporary files left behind, so that publication evidence does not create lingering risk or cost.

## Implementation Decisions

### Product and repository identity

- The public project name is `agentctl`. The executable, canonical repository, documentation title, release artifacts, and normal runtime image naming use that identity.
- The current clean V2 implementation is the canonical source. The old prototype has no preservation or migration requirement and is not copied into this project.
- The canonical source repository is the public `https://github.com/jbeers/agentctl` project. Public release artifacts remain deferred until their acceptance slices are complete. Publication occurs only from a clean checkout; agent bundles and local credentials remain operator files and are never release inputs.
- The first application release is `0.1.0-alpha.1`. Public-alpha versioning is separate from the version 2 bundle schema; application releases do not require renaming or migrating valid V2 bundles.
- The project uses the Apache License 2.0. Only the latest public-alpha release is supported unless a release notice states otherwise.

### Release and runtime distribution

- The initial supported operator artifact is Linux `amd64`. Additional operator targets are added only after MatchBox builds and real usage are verified on those platforms.
- Release automation pins MatchBox and all build dependencies rather than selecting a developer-local checkout.
- Continuous integration reuses the existing TestBox suite and native build. A release is blocked by failing tests, generated-script syntax, whitespace checks, or native smoke checks.
- Releases publish the native executable, a SHA-256 checksum, application version, and source revision metadata. A curl-pipe-shell installer, package manager, auto-updater, signing infrastructure, and multi-platform matrix are deferred until the direct artifact path proves insufficient.
- The supported Hermes runtime is built and published from the canonical repository for Linux `amd64`. It remains an appliance image, not a generic plugin interface.
- The normal runtime package is public. Operators may still select a private immutable image and provide a narrowly scoped registry credential.
- The built-in runtime default points to the currently supported immutable release. CLI and runtime compatibility are exercised before publication.
- Runtime publication retains image provenance and SBOM generation when available through the established container-build workflow.

### Website and documentation

- The website is a static documentation site in the same repository. MkDocs Material is the initial generator and GitHub Pages is the initial host.
- Existing Markdown remains the canonical content and is reorganized rather than duplicated into a second prose system.
- The homepage is product-oriented, but documentation remains the primary function. It presents the narrow Hermes, DigitalOcean, Tailscale, rootless-container, persistence, and security model honestly.
- The site contains no control-plane API, user account, hosted provisioning, database, CMS, analytics requirement, or secret input.
- A custom domain is optional and does not block launch. Naming and content are stabilized before domain purchase or search-engine promotion.
- Documentation is written for operators and Hermes users. Internal class structure and transient implementation details remain outside user guides.
- The README remains a short repository entry point and links to the canonical install and quickstart pages.
- Site builds include internal-link and navigation checks. Examples use synthetic agent names and credentials.

### Credential rotation

- Credential rotation is write-only. Supported values are selected explicitly and entered through hidden confirmation prompts.
- SOPS receives replacement values through standard input. No decrypted bundle, plaintext intermediate bundle, value-bearing process argument, or secret-bearing output is introduced.
- Rotation preserves unknown-to-the-command encrypted values by operating through the existing strict bundle and SOPS policy rather than rebuilding an agent from scratch.
- A bundle replacement is atomic and mode `0600`. Encryption and local decryption are validated before publication.
- General secret extraction remains out of scope. Operators needing unsupported edits may use SOPS directly under documented precautions.

### State export and purge

- State export is the inverse of the existing state-archive restore contract. It exports `/opt/data` only; `/workdir` remains Hermes/Git-owned and disposable.
- Export uses the existing encrypted SSH identity and private Tailscale route. It safely quiesces Hermes, flushes state, creates or streams a validated tar archive, and restores Hermes service when the operation is not part of teardown.
- The final local archive is written to a unique mode-`0600` temporary path, validated, synchronized, and atomically renamed to a previously absent requested destination.
- State archives are always treated as secret-bearing. Normal output reports success and metadata without emitting archive contents; verbose behavior remains redacted.
- Purge is a distinct destructive command and is never implied by `down`. `down` continues to retain state.
- Purge operates only when the exact Droplet is absent and exactly one expected provider volume exists detached in the configured region and size.
- Purge requires explicit agent-name confirmation and does not offer a force flag that bypasses identity, attachment, or provider-safety checks.
- Purge does not claim that a backup exists. Documentation and output require the operator to make that determination; the state-export path provides the supported portable backup mechanism.

### Machine-readable operation

- JSON is an explicit output mode on status, not a replacement for normal text.
- JSON represents the existing product states and dependency layers. It does not expose raw provider, SSH, container, or HTTP payloads.
- Exit status remains `0` only for ready. Schema fields and state vocabulary are documented and covered by compatibility tests.
- Broader JSON lifecycle output is deferred until status proves the shape needed by real automation.

### Longer-term sequencing

- A concrete backup/checkpoint destination is selected before introducing a provider abstraction for checkpoint storage.
- Automatic idle shutdown remains blocked on a machine-verifiable Hermes checkpoint and safe-to-stop contract.
- Admin Hermes integration initially invokes the same released CLI and consumes stable machine output; a permanent API or daemon is not created preemptively.
- A second compute provider is the prerequisite for extracting a provider interface. DigitalOcean remains the sole implementation in this roadmap.

## Testing Decisions

- Tests continue to assert observable commands, files, outputs, exit status, cleanup, resource selection, and trust-boundary behavior rather than private helper structure.
- Existing FakeCommandRunner patterns cover release-independent lifecycle behavior without cloud access.
- Release CI runs all 77 existing TestBox checks and adds the smallest regression checks for each new branch or parser path.
- Native release artifacts receive direct smoke checks for version output, help, bundle inspection, and generated-script syntax so JVM-only behavior cannot mask MatchBox differences.
- Runtime image tests execute the required binaries and verify the `/workdir`, rootless socket client, and Compose contract before publication.
- Documentation tests build the complete static site and reject broken internal links, missing navigation targets, and stale release placeholders.
- Credential rotation tests verify hidden-input flow, SOPS standard input, strict field selection, mode `0600`, atomic replacement, decryption validation, cancellation, and cleanup. Assertions never include replacement values or ciphertext.
- State-export tests cover a valid tree, empty state, symlinks, executable modes, interrupted transfer, destination collision, validation failure, atomic publication, mode `0600`, Hermes restart behavior, and local/remote cleanup.
- Purge tests cover absent state, duplicate volumes, attached volumes, region and size mismatch, active compute, provider indeterminacy, confirmation mismatch, exact deletion, and secret-safe output.
- Status JSON tests cover every existing layer boundary, stable keys and values, exit semantics, invalid local configuration, provider failure, and complete redaction.
- Publishing a public runtime, deleting live volumes, and executing the final public-alpha exercise are HITL activities requiring operator approval.
- The final clean-room exercise uses only published artifacts, the website, and normal operator prerequisites. No manual VM repair is permitted; automation defects are fixed, released, and retried.

## Out of Scope

- A version 3 agent-bundle schema or migration of valid V2 bundles
- Automatic current-directory bundle discovery
- A generic cloud-provider or runtime-plugin framework
- A second compute provider
- Non-Hermes agent runtimes
- Public ingress or hosted tunnels
- A browser-based provisioning control plane
- A hosted `agentctl` service, account system, database, or API daemon
- Kubernetes, Docker-in-Docker, or rootful container authority
- Arbitrary user-supplied host bootstrap scripts
- Git clone, branch, commit, push, dirty-tree, or workspace-backup behavior inside `agentctl`
- Persistence of Compose named volumes
- A general command for reading decrypted bundle secrets
- Automatic idle shutdown before a Hermes checkpoint contract exists
- NAS, Restic, S3, SFTP, or snapshot provider abstractions in the public-alpha issue set
- Admin Hermes lifecycle tools in the public-alpha issue set
- macOS, Windows, or Linux `arm64` release promises before native builds are proven
- Package-manager distribution, automatic update, or curl-pipe-shell installation
- A custom documentation backend, CMS, analytics platform, blog engine, or versioned-docs system
- A custom website domain as a release blocker
- A formal claim of third-party security audit

## Further Notes

- The V2 product and its live acceptance remain the behavioral baseline. This roadmap adds distribution and day-two workflows without reopening the deliberately narrow appliance model.
- The current documented runtime default predates the image used for V2 live acceptance and must be replaced before a public quickstart is promoted.
- The retained provider volume is working durability, not an independent backup. The website must state this prominently even after state export exists.
- `down` and `purge` remain intentionally separate. Convenient billing cleanup must not weaken the default protection against state loss.
- Tailscale enrollment credentials should remain narrowly scoped, reusable only where rebuild behavior requires it, ephemeral where supported, and rotatable before expiry.
- A public runtime image is the simplest onboarding path. Registry-token support remains because private or customized images are legitimate, not because the normal release should require one.
- The initial website should earn trust through accurate quickstart, security, persistence, cost, recovery, and limitation documentation—not through marketing volume.
- No further-provider or control-plane issues should be opened until public-alpha usage provides evidence that those abstractions are needed.
