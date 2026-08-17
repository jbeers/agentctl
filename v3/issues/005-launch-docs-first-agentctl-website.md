# Launch the docs-first agentctl website

- **Type:** AFK
- **User stories:** 44–48

## Parent

[agentctl Public Product and Adoption Specification](../PRD.md)

## What to build

Turn the proven Markdown guide set into a polished, searchable static project website. The site is the canonical entry point for installing and operating `agentctl`, not a hosted control plane. It must stay in the same repository and reuse the existing documentation rather than creating a second content source.

Use MkDocs Material and GitHub Pages unless an already-approved repository constraint makes that impossible. Keep customization limited to navigation, a small homepage, project styling, and essential metadata.

## Acceptance criteria

- [x] The site builds from repository Markdown with a pinned documentation toolchain.
- [x] Navigation includes Home, Getting Started, Concepts, Guides, Reference, Troubleshooting, Security, Roadmap, Contributing, and Releases.
- [x] Existing bundle, up, status, access, Compose, archive, and down guides are preserved and linked from the new information architecture.
- [x] The homepage positions `agentctl` narrowly as a private disposable Hermes appliance for DigitalOcean and does not imply a hosted service or generic agent framework.
- [x] The homepage shows the supported lifecycle, Tailscale-only access, rootless Compose model, durable-state/disposable-workspace split, default cost behavior, and known platform limits.
- [x] A sanitized terminal demonstration uses only synthetic resources and values.
- [x] The built site is responsive, keyboard-usable, readable with normal contrast, and includes built-in search.
- [x] CI rejects broken internal links, missing navigation targets, and unresolved release placeholders.
- [x] GitHub Pages deploys only after the site build succeeds and exposes one canonical documentation URL.
- [x] The repository README remains concise and directs users to installation, quickstart, security, and the website.
- [x] Release and runtime defaults shown on the site are sourced or checked so they cannot silently drift from the published product.
- [x] No backend, account system, provisioning API, database, CMS, analytics requirement, or secret-entry form is added.
- [x] A custom domain is optional and does not block the initial website.

## Completion evidence

- `mkdocs.yml` builds the canonical `docs/` Markdown with Python `3.13.12`, pip `26.0.1`, MkDocs `1.6.1`, and MkDocs Material `9.7.7` pinned in the repository and workflow.
- The Material site uses its established responsive, keyboard-operable controls, normal-contrast light/dark palettes, and built-in search without custom CSS or JavaScript.
- `scripts/check-docs` checks the current application release, exact built-in runtime digest, unresolved release placeholders, every fenced Bash example, complete navigation, and strict MkDocs links/anchors.
- The documentation workflow builds pull requests without publication and uploads/deploys only a successful main-branch or manually dispatched build. GitHub Actions run `32052789801` deployed revision `a037be6c7df6b5171d224007602dc08fe361967d` successfully.
- An anonymous live crawl of all 18 sitemap pages passed every internal link and anchor, responsive viewport, navigation section, search index, current `0.1.0-alpha.2` release, and exact runtime-digest check.
- GitHub Pages enforces HTTPS at [https://jbeers.github.io/agentctl/](https://jbeers.github.io/agentctl/), and the public repository homepage and concise README point to that canonical URL.
- The published site is static and contains no backend, account system, provisioning API, database, CMS, analytics, or secret-entry form. No custom domain was needed.

## Blocked by

None — complete.
