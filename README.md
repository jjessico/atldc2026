# On Demand Environments for Coding Agents

Gists from the ATL Developers Conference 2026 talk *On Demand Environments for Coding Agents*. The technical highlights are in [CONCEPTS.md](CONCEPTS.md).

## Files

| Option | File | What it is |
| --- | --- | --- |
| Localhost (Tart) | [src/tart/tahoe-ai-apps.pkr.hcl](src/tart/tahoe-ai-apps.pkr.hcl) | Packer template that builds a macOS Tahoe Tart image with the Claude and ChatGPT apps |
| Remote server (microsandbox) | [src/microsandbox/agents.yaml](src/microsandbox/agents.yaml) | microVM config with an allowlisted network and a `setup` script for Claude Code, Codex and OpenCode |
| Hybrid (Docker Sandboxes) | [src/docker_sbx/sbxenv.yaml](src/docker_sbx/sbxenv.yaml) | Local sandbox environment with read-write and read-only workspaces |
| | [src/docker_sbx/sbxenv.cloud.yaml](src/docker_sbx/sbxenv.cloud.yaml) | The cloud version of the same environment (no host mounts) |
| | [src/docker_sbx/kits/cloud-clis/](src/docker_sbx/kits/cloud-clis/spec.yaml) | Kit that adds the AWS CLI and wrangler, with a proxy-managed Cloudflare token |
| | [src/docker_sbx/kits/zsh-shell/](src/docker_sbx/kits/zsh-shell/spec.yaml) | Kit that adds zsh, oh-my-zsh, starship and tmux, with dotfiles |
