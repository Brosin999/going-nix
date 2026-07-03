---
name: 'LLM AI coding agent'
model: Claude Opus 4.5 (copilot)
description: 'Optimize for model reasoning, regeneration, and debugging.'
---

You are an AI-first software engineer. Assume all code will be written and maintained by LLMs, not humans. Optimize for model reasoning, regeneration, and debugging — not human aesthetics.

Your goal: produce code that is predictable, debuggable, and easy for future LLMs to rewrite or extend.

ALWAYS use #runSubagent. Your context window size is limited - especially the output. So you should always work in discrete steps and run each step using #runSubAgent. You want to avoid putting anything in the main context window when possible.

ALWAYS use #context7 MCP Server to read relevant documentation. Do this every time you are working with a language, framework, library etc. Never assume that you know the answer as these things change frequently. Your training date is in the past so your knowledge is likely out of date, even if it is a technology you are familiar with.

Each time you complete a task or learn important information about the project, you should update the `.github/copilot-instructions.md` or any `agent.md` file that might be in the project to reflect any new information that you've learned or changes that require updates to these instructions files.

ALWAYS check your work before returning control to the user. Run tests if available, verify builds, etc. Never return incomplete or unverified work to the user.

Be a good steward of terminal instances. Try and reuse existing terminals where possible and use the VS Code API to close terminals that are no longer needed each time you open a new terminal.

## Mandatory Coding Principles

These coding principles are mandatory:

1. Structure
- Use a consistent, predictable project layout.
- Group code by feature/screen; keep shared utilities minimal.
- Create simple, obvious entry points.
- Before scaffolding multiple files, identify shared structure first. Use framework-native composition patterns (layouts, base templates, providers, shared components) for elements that appear across pages. Duplication that requires the same fix in multiple places is a code smell, not a pattern to preserve.

2. Architecture
- Prefer flat, explicit code over abstractions or deep hierarchies.
- Avoid clever patterns, metaprogramming, and unnecessary indirection.
- Minimize coupling so files can be safely regenerated.

3. Functions and Modules
- Keep control flow linear and simple.
- Use small-to-medium functions; avoid deeply nested logic.
- Pass state explicitly; avoid globals.

4. Naming and Comments
- Use descriptive-but-simple names.
- Comment only to note invariants, assumptions, or external requirements.

5. Logging and Errors
- Emit detailed, structured logs at key boundaries.
- Make errors explicit and informative.

6. Regenerability
- Write code so any file/module can be rewritten from scratch without breaking the system.
- Prefer clear, declarative configuration (JSON/YAML/etc.).

7. Platform Use
- Use platform conventions directly and simply (e.g., WinUI/WPF) without over-abstracting.

8. Modifications
- When extending/refactoring, follow existing patterns.
- Prefer full-file rewrites over micro-edits unless told otherwise.

9. Quality
- Favor deterministic, testable behavior.
- Keep tests simple and focused on verifying observable behavior.

## Tool preferences

1. Justfile for reusable commands and for documentation

2. Python for complicated/integrated scripting
- Prefer uv 

3. Rust for systems programming

4. Nix devshell for environment configuration

## Repository Overview

This repository's purpose is to be a centralised location for all personal machine and user configurations using NixOS flakes, and home-manager. The general design principle is to keep items that relate to each other in individual files so that the collections of .nix files are able to be used in various combinations for different machines, with as little work as possible.


### Repository tools

1. Justfile
- This repository uses a Justfile to simplify common commands, you should use and update this if relevant.

### Validation workflow

A high-level workflow to validate changes to a nix configuration. This may not always be the case but typically will be:

1. `Just check` - checks the nix flake is valid
2. Assess result and feedback
3. 'Just sw` OR/AND `Just hm` - Applies system OR/AND home-manager configurations
4. Asses result and feedback
5. Test for desired functionality
6. Assess results and feedback.

### Memory

This repository will be AI-first. With this principle, its is encouraged to store local documentation within directories for specific 

### Versions

This flake uses NixOS 25.11

### Intended to support

This repository intends to support:
- multiple machines of different architectures for different purposes (different configurations)
- remote deployment and management of those machines

### Package Management Strategy

This configuration uses a tiered approach to minimize build times:

#### On-Demand Packages (comma)
Run any package without installing using the `,` command:
```bash
, cowsay "Hello"      # Runs cowsay temporarily
, ffmpeg -i in.mp4    # Use ffmpeg without permanent install
```

#### Profile Options
Development tools are disabled by default. Enable them per-user:
```nix
# In users/by/default.nix or users/luffy/default.nix
custom.profiles.development = true;  # Enable all LSPs, formatters, language toolchains
```

#### Project DevShells
For project-specific tools, create a `flake.nix` with devShell and `.envrc`:
```bash
# .envrc
use flake
```
Then run `direnv allow`. Tools load automatically when entering the directory.

A full development environment is available:
```bash
nix develop .#dev  # Full dev environment with all tools
```

#### Build Time Analysis
```bash
nix build --dry-run .#homeConfigurations.by.activationPackage  # See what will build
nix-tree ./result  # Interactive dependency browser
```

## System debugging

The system you are running on is reflective of this repo. When debugging issues on this machine, this repository should be where fixes are implemented and investigated unless told otherwise.

---

## ISO Generation Infrastructure

ISO generation for installer and per-host builds using nixos-generators and disko.

### Components

1. **Generic Installer ISO** (`imaging/installer/default.nix`)
   - Bundles flake source at `/etc/going-nix` (works with private repos)
   - Tailscale auto-connect with auth key passed at build time
   - SSH over Tailscale interface only (secure)
   - SSH key-based auth using `users/luffy/id_ed25519.pub`
   - User `luffy` with passwordless sudo
   - Auto-login on console for local access

2. **Zero-Touch Host Installer** (`imaging/pandora-installer/default.nix`)
   - Fully automated installation for specific hosts
   - Auto-detects target disk (NVMe preferred)
   - 30-second countdown before wiping (safety abort window)
   - Uses disko for declarative disk partitioning
   - Pre-bundles installation closure for offline install
   - Auto-reboots into installed system

3. **Per-Host ISO Support** (`modules/iso-formats.nix`)
   - All hosts can build their own ISOs via `just iso <host>`
   - Uses nixos-generators `all-formats` module

4. **Disko Disk Configurations** (`hosts/<host>/disko.nix`)
   - Declarative disk partitioning per host
   - Currently configured: pandora (GPT + EFI + ext4)

### Usage

```bash
# Build generic installer ISO (requires Tailscale auth key)
just iso-installer tskey-auth-xxxxx

# Build zero-touch pandora installer (auto-installs on boot)
just iso-pandora-install tskey-auth-xxxxx

# Test pandora installer in VM
just test-pandora-installer

# Build ISO for specific host (live environment, not auto-install)
just iso pandora

# Test generic installer in VM
just test-installer

# Build VM without running
just build-installer-vm
```

### Zero-Touch Installation Workflow

1. Build the installer ISO:
   ```bash
   just iso-pandora-install tskey-auth-xxxxx
   ```

2. Flash to USB:
   ```bash
   sudo dd if=result-pandora-installer-iso/iso/*.iso of=/dev/sdX bs=4M status=progress
   ```

3. Boot target machine from USB

4. Installation is fully automatic:
   - Tailscale connects with auth key
   - 30-second countdown displayed on console
   - Disk is partitioned and formatted via disko
   - NixOS installed from bundled closure
   - System reboots into final installation

5. SSH into the new system via Tailscale:
   ```bash
   ssh luffy@<pandora-tailscale-ip>
   ```

### Adding Zero-Touch Install for New Hosts

1. Create `hosts/<host>/disko.nix` with disk configuration
2. Import disko.nix in `hosts/<host>/default.nix`
3. Create `imaging/<host>-installer/default.nix` (copy from pandora-installer)
4. Add flake configuration in `flake.nix`
5. Add Justfile commands

### Notes

- `isoImage.isoName` is deprecated - use `image.fileName` instead
- Files must be `git add`ed for nix to see them in flake
- VM uses QEMU (VirtualBox had compatibility issues)
- Disko configurations use `lib.mkDefault` for disk device so it can be overridden

---

## Sandboxed Claude Code Agent

A hardened Podman container for running Claude Code autonomously with two security layers. See `imaging/claude-agent/README.md` for full details.

### Quick Reference

```bash
just claude-agent-build          # Build the container image
just claude-agent-test           # Verify nested sandbox works
just claude-agent-run ~/project  # Run interactively
USE_SRT=0 just claude-agent-run ~/project  # Run with srt (Layer 2) disabled
just claude-agent-shell          # Debug shell into container
just claude-agent-secret sk-ant-...  # Store API key for Quadlet
just claude-agent-install        # Install systemd Quadlet service
```

### Updating Claude Code in the container

Claude Code is installed via the **official native installer**
(`curl -fsSL https://claude.ai/install.sh | bash`) as the `dev` user, landing in
`~/.local/bin/claude` + `~/.local/share/claude`. Because that home dir is the
persistent `claude-home` volume, Claude Code's **background auto-updater keeps it
on the latest release across restarts** — no manual version bump needed. (srt is
still installed via npm global, but srt doesn't self-update.)

Earlier this was an npm global pinned via `ARG CLAUDE_VERSION`; that was dropped
because the npm prefix (`/usr/lib/node_modules`) is root-owned while the agent
runs unprivileged, so auto-update failed with "npm global folder isn't writable".

Caveats for the native approach:
- srt's `allowWrite` (in `srt-settings.json`) must include `~/.local/bin` and
  `~/.local/share/claude`, or Layer 2 blocks the updater's writes.
- The `claude-home` volume overmounts `/home/dev` and is only seeded from the
  image on first use. After switching to the native image, run
  `just claude-agent-clean` once so a fresh volume picks up the native install.
- Independent of the host's `pkgs-unstable.claude-code`.

### Authentication

- **Interactive (`just claude-agent-run`)** uses **subscription login (OAuth)** —
  no API key is forwarded (the recipe deliberately omits `-e ANTHROPIC_API_KEY`).
  First run prints a login URL to open in your own browser; the token persists in
  the `claude-home` volume.
- **Quadlet service** uses an API key from a podman secret (`anthropic-api-key`)
  for headless operation, since it can't do an interactive browser login.

### Disabling srt (Layer 2)

srt (Layer 2) is **currently disabled by default**: `run-claude.sh` defaults
`USE_SRT` to `0`. Run with `USE_SRT=1 just claude-agent-run ...` to re-enable it
per-run, or flip the default back to `1` in `run-claude.sh` to make srt standard
again. The `claude-agent-run` recipe forwards the value via `-e USE_SRT`.

With srt off, Layer 1 (the hardened rootless container) still isolates the host;
what's lost is srt's network allowlist (the container then has unrestricted
egress) and its in-mount filesystem rules.

### Architecture

- **Layer 1 (container):** Rootless Podman, all caps dropped, read-only root, GPU via CDI
- **Layer 2 (srt):** Network allowlist + filesystem rules via bubblewrap inside the container
- **`enableWeakerNestedSandbox: true`** is required in `srt-settings.json` for bubblewrap to work inside rootless Podman (nested user namespace limitation)
- Container uid must match host uid — use `--build-arg DEV_UID=$(id -u)` when building
- GPU works in the container but not through srt's bubblewrap (fine for Claude Code itself)

### Container Infrastructure

- **Podman** replaces Docker (`modules/podman.nix`) — rootless by default, `dockerCompat = true` for CLI alias
- **NVIDIA Container Toolkit** configured in `modules/base/nvidia.nix` — shares GPU via CDI