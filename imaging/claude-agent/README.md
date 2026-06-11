# Sandboxed Claude Code Agent

A hardened container environment for running `claude-code` autonomously with GPU access, using two independent security layers.

## Security Model

Two independent boundaries (defense in depth):

1. **The container** (Layer 1) — rootless Podman, unprivileged user, all capabilities dropped, no-new-privileges, read-only root filesystem. This is the OS boundary.
2. **srt (sandbox-runtime)** (Layer 2) — wraps the whole Claude process *inside* the container and enforces a network allowlist + filesystem rules. Independent of layer 1.

The GPU is **shared via CDI** (Container Device Interface), not passed through. CUDA runs at native speed concurrently with your desktop. The trade-off vs a VM: a container shares your kernel, so this is a kernel-level (not hardware-level) boundary.

## Prerequisites

These are already configured in the flake:

- **NVIDIA driver + container toolkit**: `modules/base/nvidia.nix` (sets `hardware.nvidia-container-toolkit.enable = true`)
- **Rootless Podman**: `modules/podman.nix` (replaced Docker — Podman is rootless by default, no daemon)

## Files

| File | Purpose |
|------|---------|
| `Containerfile` | Container image: CUDA runtime + Node.js + Nix + direnv + Claude Code + srt |
| `run-claude.sh` | Entrypoint: wraps Claude inside srt's sandbox |
| `srt-settings.json` | Network allowlist + filesystem rules for srt |
| `claude-agent.container` | Quadlet: systemd-managed container service definition |
| `README.md` | This file |

## Setup

### 1. Build the container image

```bash
just claude-agent-build
```

The `DEV_UID` build arg is set to your uid automatically. This ensures files created inside volume mounts are owned by your host user.

### 2. Verify GPU reaches the container

```bash
podman run --rm --device nvidia.com/gpu=all \
  --security-opt=label=disable \
  nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

You should see your GPU. If `libcuda.so` isn't found, confirm `hardware.nvidia-container-toolkit.enable` is set and you've run `just sw`.

### 3. Verify the nested sandbox works

```bash
just claude-agent-test
```

This tests srt's bubblewrap inside the container. You should see `ok` printed.

### 4. Create the API key secret

```bash
printf '%s' "sk-ant-..." | podman secret create anthropic-api-key -
```

### 5. Run interactively (recommended first)

```bash
just claude-agent-run ~/my-project
```

This runs Claude Code in the sandboxed container with your project mounted.

### 6. (Optional) Set up as a systemd service via Quadlet

For autonomous/persistent operation:

```bash
mkdir -p ~/.config/containers/systemd
cp imaging/claude-agent/claude-agent.container ~/.config/containers/systemd/
systemctl --user daemon-reload
systemctl --user start claude-agent
journalctl --user -u claude-agent -f
```

## Nuances and Gotchas

### Nested bubblewrap requires `enableWeakerNestedSandbox`

srt uses bubblewrap internally to create filesystem/process isolation. Running bubblewrap inside an already-rootless Podman container is a nested user namespace scenario. Without `enableWeakerNestedSandbox: true` in `srt-settings.json`, bubblewrap fails with:

```
bwrap: Can't create file at /home/dev/project/.env: Permission denied
```

The `enableWeakerNestedSandbox` flag tells srt to skip mounting a fresh `/proc` (which requires capabilities unavailable in a nested namespace). The network allowlist, filesystem rules, and process isolation all still apply.

### Container uid must match host uid

The Containerfile creates a `dev` user whose uid must match your host uid. If they don't match, volume mounts will have wrong ownership and bubblewrap bind mounts fail with permission errors.

The `DEV_UID` build arg handles this:

```bash
podman build --build-arg DEV_UID=$(id -u) -t claude-agent:latest .
```

If you see permission errors on the project directory inside the container, this is almost certainly a uid mismatch. Rebuild the image with the correct uid.

### GPU access works in the container but NOT through srt

The GPU is accessible inside the container (Layer 1) via CDI. However, srt's bubblewrap (Layer 2) creates a minimal `/dev` that doesn't include the NVIDIA device nodes. This means:

- `nvidia-smi` works when bypassing srt (`USE_SRT=0`)
- `nvidia-smi` fails when running through srt
- This is fine for Claude Code itself (it's an LLM CLI, not running local inference)
- If the code Claude *writes* needs CUDA at runtime, test it outside srt or extend srt's device passthrough

### CUDA version coupling

The container's CUDA version (12.4.0 in the Containerfile) must be supported by your host NVIDIA driver. NVIDIA drivers are backward-compatible (newer driver runs older CUDA), but not forward-compatible. After a NixOS upgrade bumps the driver, verify with step 2 above.

### Read-only root is disabled (GPU compatibility)

The original design used `--read-only` to make the container root filesystem immutable. This is currently **disabled** because the NVIDIA CDI hook needs to write library mount points into the container filesystem at startup. With `--read-only`, the container fails with:

```
error executing hook nvidia-cdi-hook (exit code: 1)
```

This is an acceptable trade-off because:
- The container is **rootless** — the process runs as your unprivileged user, not root, so it can't write to most system paths
- **`--cap-drop=ALL`** prevents privilege escalation
- **srt** (Layer 2) still restricts filesystem writes to the project dir and `/tmp`
- The container is **ephemeral** (`--rm`) — any modifications are discarded on exit

**TODO:** Investigate the exact paths the CDI hook writes to and add targeted writable tmpfs mounts, re-enabling `--read-only` for the rest of the filesystem.

Writable surfaces:
- `/home/dev` — named volume (`claude-home`), persists agent state (`.claude/`, Nix store caches)
- `/home/dev/project` — bind mount to your project directory

### Network egress control

srt's network allowlist (`srt-settings.json` → `network.allowedDomains`) is your main exfiltration control. The default list covers:

- `api.anthropic.com` — required for Claude to function
- npm/pypi/GitHub — typical dev work dependencies

Trim or extend based on your needs. Keep it tight — this is the practical egress boundary. Filtering rootless container egress at the host (nftables) is awkward due to pasta/slirp4netns networking.

### Nix devshells and direnv

The container includes the Nix package manager (single-user install) with flakes enabled, plus direnv and nix-direnv. This means projects with `flake.nix` + `.envrc` get their devshell tools automatically.

**How it works inside the container:**
- Nix store lives at `/nix` (baked into the image, persisted via the `claude-home` volume at `/home/dev`)
- `nix develop` works for any mounted project with a `flake.nix`
- `direnv` auto-activates devshells when Claude `cd`s into a project with `.envrc`
- Binary caches (`cache.nixos.org`) are fetched over the network — ensure `cache.nixos.org` is in `srt-settings.json` if using srt's network allowlist

**Important:** The Nix store is large. The `claude-home` named volume persists `/home/dev` (including the nix profile and cached derivations) across container restarts. Without this volume, every restart re-downloads everything.

**Why Ubuntu+Nix instead of a NixOS container:** The `nixos/nix` image isn't actually NixOS (no systemd, no module system). More critically, nvidia-container-toolkit mounts GPU libraries at FHS paths (`/usr/lib64/`) which Nix-built binaries can't find without `LD_LIBRARY_PATH` hacks. Ubuntu provides the FHS layout for GPU access; Nix runs on top for devshell tooling.

### Nix store and the network allowlist

If srt's network allowlist is active, Nix needs to reach the binary cache. Add these to `srt-settings.json` → `network.allowedDomains`:

```json
"cache.nixos.org",
"*.cache.nixos.org"
```

Without these, `nix develop` will fail to fetch derivations. The current default allowlist does not include them — add them if you want devshell support through srt.

### Podman vs Docker

This setup uses Podman (not Docker) because:

- **Rootless by default** — no root daemon, container escape gives unprivileged user
- **No daemon** — no background process consuming resources
- **`dockerCompat = true`** in the flake provides the `docker` CLI alias if needed
- **Quadlet** — native systemd integration for managing container services

### Debugging

```bash
# Bypass srt to test container-only (Layer 1 only):
podman run --rm --entrypoint /bin/bash --device nvidia.com/gpu=all \
  --security-opt=label=disable --group-add keep-groups --userns=keep-id \
  -v ~/my-project:/home/dev/project:rw \
  localhost/claude-agent:latest -c 'claude --version'

# Debug srt initialization:
podman run --rm --entrypoint /bin/bash --device nvidia.com/gpu=all \
  --security-opt=label=disable --group-add keep-groups --userns=keep-id \
  -v ~/my-project:/home/dev/project:rw \
  localhost/claude-agent:latest -c 'SRT_DEBUG=1 srt --settings ~/.srt-settings.json echo ok'

# Check uid mapping:
podman run --rm --entrypoint /bin/bash --userns=keep-id \
  localhost/claude-agent:latest -c 'id'
# Should show your host uid, not 1000

# Shell into the container:
podman run --rm -it --entrypoint /bin/bash --device nvidia.com/gpu=all \
  --security-opt=label=disable --group-add keep-groups --userns=keep-id \
  -v ~/my-project:/home/dev/project:rw \
  localhost/claude-agent:latest
```

## When to Graduate to a VM

If you later add a second GPU for the host display, pass the main card through with VFIO and promote this from a kernel-shared container to a hardware-isolated VM (microvm.nix + cloud-hypervisor). The srt allowlist and hardening posture carry over.
