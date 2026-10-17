# Technical Highlights

## Option 1: Localhost virtualization (Tart)

- [Tart](https://tart.run) uses Apple's built-in Virtualization framework to run macOS VMs on a Mac.
- Pull a prebuilt image and boot it:
  ```sh
  tart clone ghcr.io/cirruslabs/macos-tahoe-base:latest quick-tahoe
  tart run quick-tahoe
  ```
- Build a custom image as code with HashiCorp Packer ([tahoe-ai-apps.pkr.hcl](src/tart/tahoe-ai-apps.pkr.hcl)), then clone it as many times as you want:
  ```sh
  packer build tahoe-ai-apps.pkr.hcl
  tart clone tahoe-ai-apps atldc-demo-1
  tart run atldc-demo-1
  ssh admin@"$(tart ip atldc-demo-1)"
  ```

## Option 2: Remote server (microsandbox)

- `tmux` keeps an agent session running after you disconnect:
  ```sh
  tmux new -s persistent_claude   # detach with Ctrl+b, then d
  tmux attach -t persistent_claude
  ```
- [microsandbox](https://microsandbox.dev) (`msb`) runs lightweight microVMs from OCI images:
  ```sh
  msb create alpine --name generic_vm -c 2 -m 1G
  msb exec -t generic_vm
  ```
- **Build once, snapshot, restore many.** [agents.yaml](src/microsandbox/agents.yaml) sets the CPU, memory, mounts and a strict network allowlist, plus a `setup` script that installs the agent CLIs. You snapshot the disk, and each restore boots with the tools already installed:
  ```sh
  msb create --conf agents.yaml --name agents_base
  msb exec agents_base -- setup
  msb snap create ready --sandbox agents_base
  msb restore agents_base:ready --name agent-vm-1 -v ./agent_workspace:/workspace
  ```
- **Snapshot vs. fork:** `msb fork` clones a *running* VM, including its RAM, CPU and interrupt state. That needs a GICv3 ARM host or x86 KVM, so it fails on a Raspberry Pi (GICv2). A disk-only snapshot works on cheap hardware: each copy costs a boot instead of a reinstall.

## Option 3: Hybrid (Docker Sandboxes)

- `sbx` runs agents in sandboxes that work locally or in the cloud:
  ```sh
  sbx run -d --name claude-vm claude agent_workspace
  ```
- **Environment as a file:** [sbxenv.yaml](src/docker_sbx/sbxenv.yaml) declares the agent, a read-write workspace, read-only reference workspaces, env vars, sizing and kits.
  ```sh
  sbx env run -d ./sbxenv.yaml
  sbx exec -it claude-custom-vm zsh
  ```
- **Kits** are mixins you can combine. Each one adds its install steps, network allow rules and agent instructions ([cloud-clis](src/docker_sbx/kits/cloud-clis/spec.yaml), [zsh-shell](src/docker_sbx/kits/zsh-shell/spec.yaml)).
- **Network policy in layers:** a global preset (`sbx policy init balanced`), with per-sandbox allow rules from kits added on top.
- **Credentials stay on the host:** with a proxy-managed credential, the sandbox only sees a placeholder. The proxy adds the real token to outbound requests for the domains you allow.
- **Move to the cloud while it runs,** with a time-to-live so cost stays bounded:
  ```sh
  sbx move claude-custom-vm --to cloud --name claude-custom-vm --ttl 2h --on-timeout stop
  sbx --cloud env run -d --name demo-1 --ttl 8h --on-timeout stop ./sbxenv.cloud.yaml
  ```
  Cloud sandboxes can't mount host directories, so [sbxenv.cloud.yaml](src/docker_sbx/sbxenv.cloud.yaml) leaves out the workspaces.
