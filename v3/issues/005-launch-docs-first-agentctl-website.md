# Launch the docs-first agentctl website

- **Type:** AFK
- **User stories:** 44–48

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Turn the proven Markdown guide set into a polished, searchable static project website. The site is the canonical entry point for installing and operating `agentctl`, not a hosted control plane. It must stay in the same repository and reuse the existing documentation rather than creating a second content source.

Use MkDocs Material and GitHub Pages unless an already-approved repository constraint makes that impossible. Keep customization limited to navigation, a small homepage, project styling, and essential metadata.

## Acceptance criteria

- [ ] The site builds from repository Markdown with a pinned documentation toolchain.
- [ ] Navigation includes Home, Getting Started, Concepts, Guides, Reference, Troubleshooting, Security, Roadmap, Contributing, and Releases.
- [ ] Existing bundle, up, status, access, Compose, archive, and down guides are preserved and linked from the new information architecture.
- [ ] The homepage positions `agentctl` narrowly as a private disposable Hermes appliance for DigitalOcean and does not imply a hosted service or generic agent framework.
- [ ] The homepage shows the supported lifecycle, Tailscale-only access, rootless Compose model, durable-state/disposable-workspace split, default cost behavior, and known platform limits.
- [ ] A sanitized terminal demonstration uses only synthetic resources and values.
- [ ] The built site is responsive, keyboard-usable, readable with normal contrast, and includes built-in search.
- [ ] CI rejects broken internal links, missing navigation targets, and unresolved release placeholders.
- [ ] GitHub Pages deploys only after the site build succeeds and exposes one canonical documentation URL.
- [ ] The repository README remains concise and directs users to installation, quickstart, security, and the website.
- [ ] Release and runtime defaults shown on the site are sourced or checked so they cannot silently drift from the published product.
- [ ] No backend, account system, provisioning API, database, CMS, analytics requirement, or secret-entry form is added.
- [ ] A custom domain is optional and does not block the initial website.

## Blocked by

- [004 — Complete a clean-room first-agent guide](004-complete-clean-room-first-agent-guide.md)
