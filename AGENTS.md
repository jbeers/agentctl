# AGENTS.md

## Project Purpose

Agentctl provisions disposable VMs that run a
persistent Hermes coding agent. VMs join Tailscale, use rootless Podman,
and attach one persistent Block Storage volume per agent.

Right now we are focusing on Digital Ocean support but will eventually add other providers. 

Implementation should primarily follow the work outlined in `./v2/PRD.md` and the issues in `./v2/issues/*.md`.

This will be a v2 implementation of the project in `../cloud-agent-coder`. The PRD is authorative but you can use the cloud-agent-coder project for reference to answer questions.


## Technology

The program will be written in BoxLang using MatchBox to configure platform binaries. External files like bash scripts, auxilery files, etc... should be included in the binary. 

Use TestBox for tests.

You can access a local copy of MatchBox at `~/dev/ortus-boxlang/matchbox`. You can modify MatchBox if necessary. Ask for guidance before making changes. As a rule we want to put as much Rust/native code in MatchBox and improve that projects utility and try to keep 100% of agentctl in BoxLang script for quick compiles/bundles.


## Engineering Principles

- Do not preserve backward compatibility. Remove obsolete paths instead of adding compatibility layers, fallbacks, or migrations.
- Choose the simplest implementation that fully meets the current requirements. Avoid speculative abstractions, configuration, and indirection.
- Grow the system in layers. Start from the smallest version that works end to end, and add each new capability on top of a product that already works. Never trade a working product for unfinished complexity.
- Keep components modular and concerns clearly separated.
- Prefer established, well-maintained libraries when they reduce overall complexity or improve reliability. Do not reimplement common functionality without a clear reason.
- Lean on the dependencies already in the project before writing your own implementation or adding packages. Do not assume a library lacks a capability without checking its documentation and types.
- Make architectural decisions for the long term. Do not accept a stopgap that only works for now and is meant to be replaced later.

## Warnings

DO NOT use "brigade", "brigade-dev", or any variant including the word "brigade" for testing. I have an exsting agent in Digital Ocean that I do not want to mess with.

## Documentation

I want to be able to share this project with other developers so developer friendly documentation is imperative. As you work document features clearly in the `./docs` folder. Write the documentation for the end user as an audience. Focus on usage and behavior not implementation or architecture.