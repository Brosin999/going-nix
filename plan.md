# Multi-Platform Deployment Abstraction Plan

## Goal
Create a reusable deployment module system that supports zero-touch installation across x86_64 and ARM64 platforms with platform-specific boot handling.

## Architecture Overview

```
modules/
├── deployment/
│   ├── base.nix              # Common: Tailscale, SSH, users, packages
│   ├── auto-install.nix      # Auto-installation service (parameterized)
│   ├── notifications.nix     # Webhook notification system
│   └── platforms/
│       ├── x86-efi.nix       # x86_64 UEFI boot (ISO format)
│       ├── arm64-sd.nix      # Generic ARM64 SD card boot
│       └── rockchip.nix      # Rockchip-specific (SPI flash for NVMe boot)

imaging/
├── templates/
│   └── host-installer.nix    # Template for new host installers
├── installer/                # Generic manual installer (existing)
└── pandora-installer/        # Refactored to use modules
```

## Implementation Steps

### Phase 1: Extract Common Deployment Modules

**1.1 Create `modules/deployment/base.nix`**
Extract from `imaging/pandora-installer/default.nix`:
- Tailscale auto-connect service
- SSH over Tailscale configuration
- Installer user (luffy) with SSH key
- Passwordless sudo for wheel
- Console auto-login
- Common packages (git, neovim, parted, disko, jq, curl)

Parameters:
- `deployment.user` - installer username (default: "luffy")
- `deployment.sshKeyPath` - path to authorized_keys
- `deployment.tailscale.enable` - enable Tailscale (default: true)

**1.2 Create `modules/deployment/auto-install.nix`**
Extract the auto-installation service pattern.

Parameters:
- `deployment.autoInstall.enable`
- `deployment.autoInstall.hostName` - target NixOS configuration
- `deployment.autoInstall.diskLabel` - disko disk label (default: "main")
- `deployment.autoInstall.diskSearchOrder` - list of device paths to try
- `deployment.autoInstall.countdownSeconds` - safety delay (default: 30)
- `deployment.autoInstall.postInstallCommands` - extra commands before reboot

**1.3 Create `modules/deployment/notifications.nix`**
Extract webhook notification system.

Parameters:
- `deployment.notify.url` - webhook URL (empty = disabled)
- `deployment.notify.title` - notification title
- `deployment.notify.onSuccess` - message on success
- `deployment.notify.onFailure` - message on failure

### Phase 2: Platform-Specific Modules

**2.1 Create `modules/deployment/platforms/x86-efi.nix`**
For x86_64 UEFI systems (current pandora pattern):
- ISO format configuration (EFI + USB bootable)
- VM testing configuration (4GB RAM, secondary disk)
- Disk search order: nvme → sda → vdb → vda

**2.2 Create `modules/deployment/platforms/arm64-sd.nix`**
For generic ARM64 SD card boot:
- SD card image format (`sd-aarch64-installer`)
- Disk search order: nvme → mmcblk1 → sda
- Handles SD-to-NVMe installation pattern

**2.3 Create `modules/deployment/platforms/rockchip.nix`**
Extends arm64-sd.nix for Rockchip boards (Rock5B):
- Includes u-boot/UEFI for RK3588
- SPI flash command after NVMe installation
- Includes `rkdeveloptool` in packages

### Phase 3: Host Installer Template

**3.1 Create `imaging/templates/host-installer.nix`**
Template that new host installers copy and customize:

```nix
{ inputs, lib, pkgs, modulesPath, ... }:
let
  # === CUSTOMIZE THESE ===
  hostName = "HOSTNAME";           # Target NixOS configuration name
  platform = "x86-efi";            # or "arm64-sd", "rockchip"
  diskSearchOrder = [ "/dev/nvme0n1" "/dev/sda" ];
  # === END CUSTOMIZE ===
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.nixos-generators.nixosModules.all-formats
    "${inputs.self}/modules/deployment/base.nix"
    "${inputs.self}/modules/deployment/auto-install.nix"
    "${inputs.self}/modules/deployment/notifications.nix"
    "${inputs.self}/modules/deployment/platforms/${platform}.nix"
  ];

  deployment = {
    autoInstall = {
      enable = true;
      inherit hostName diskSearchOrder;
    };
  };
}
```

### Phase 4: Refactor Existing Infrastructure

**4.1 Refactor `imaging/pandora-installer/default.nix`**
Replace ~150 lines with template usage:
```nix
{ inputs, lib, pkgs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.nixos-generators.nixosModules.all-formats
    "${inputs.self}/modules/deployment/base.nix"
    "${inputs.self}/modules/deployment/auto-install.nix"
    "${inputs.self}/modules/deployment/notifications.nix"
    "${inputs.self}/modules/deployment/platforms/x86-efi.nix"
  ];

  deployment = {
    autoInstall = {
      enable = true;
      hostName = "pandora";
      diskSearchOrder = [ "/dev/nvme0n1" "/dev/nvme1n1" "/dev/sda" "/dev/vdb" "/dev/vda" ];
    };
  };
}
```

**4.2 Refactor `imaging/installer/default.nix`**
Use base.nix but without auto-install:
```nix
deployment.autoInstall.enable = false;
```

### Phase 5: Multi-Architecture Support in Flake

**5.1 Update `flake.nix`**
Add helper function for installer configurations:

```nix
let
  mkInstaller = { system, hostName, platform }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs pkgs-unstable; };
      modules = [ ./imaging/${hostName}-installer ];
    };
in {
  nixosConfigurations = {
    # Existing hosts...

    # Installers
    pandora-installer = mkInstaller {
      system = "x86_64-linux";
      hostName = "pandora";
      platform = "x86-efi";
    };

    # Future ARM host example:
    # rock5b-installer = mkInstaller {
    #   system = "aarch64-linux";
    #   hostName = "rock5b";
    #   platform = "rockchip";
    # };
  };
}
```

**5.2 Enable cross-compilation** (for building ARM images on x86_64)
Document in CLAUDE.md:
```nix
# On x86_64 build host, enable:
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

### Phase 6: Update Justfile

Add platform-aware commands:

```just
# Build installer for any host with optional notification
iso-install host tsAuthKey notifyUrl="":
    TAILSCALE_AUTH_KEY={{tsAuthKey}} NOTIFY_URL={{notifyUrl}} \
    nix build .#nixosConfigurations.{{host}}-installer.config.formats.iso \
    -o result-{{host}}-installer --impure

# Build SD card image for ARM hosts
sd-install host tsAuthKey notifyUrl="":
    TAILSCALE_AUTH_KEY={{tsAuthKey}} NOTIFY_URL={{notifyUrl}} \
    nix build .#nixosConfigurations.{{host}}-installer.config.formats.sd-aarch64-installer \
    -o result-{{host}}-installer --impure

# Test any installer in VM
test-install host:
    nix build .#nixosConfigurations.{{host}}-installer.config.formats.vm \
    -o result-{{host}}-installer-vm --impure
    ./result-{{host}}-installer-vm/run-nixos-vm
```

## Files to Modify

| File | Action |
|------|--------|
| `modules/deployment/base.nix` | **CREATE** - Common deployment infrastructure |
| `modules/deployment/auto-install.nix` | **CREATE** - Auto-install service module |
| `modules/deployment/notifications.nix` | **CREATE** - Webhook notifications |
| `modules/deployment/platforms/x86-efi.nix` | **CREATE** - x86 UEFI platform |
| `modules/deployment/platforms/arm64-sd.nix` | **CREATE** - ARM64 SD platform |
| `modules/deployment/platforms/rockchip.nix` | **CREATE** - Rockchip specifics |
| `imaging/templates/host-installer.nix` | **CREATE** - Template for new installers |
| `imaging/pandora-installer/default.nix` | **REFACTOR** - Use new modules |
| `imaging/installer/default.nix` | **REFACTOR** - Use base module |
| `flake.nix` | **MODIFY** - Add mkInstaller helper |
| `Justfile` | **MODIFY** - Add platform-aware commands |
| `CLAUDE.md` | **UPDATE** - Document new deployment system |

## Adding a New Host Installer (Post-Implementation)

1. Create host config with disko: `hosts/<name>/disko.nix`
2. Copy template: `cp imaging/templates/host-installer.nix imaging/<name>-installer/default.nix`
3. Edit template: Set `hostName`, `platform`, `diskSearchOrder`
4. Add to flake.nix: `<name>-installer = mkInstaller { ... }`
5. Build: `just iso-install <name> <tailscale-key>` or `just sd-install <name> <tailscale-key>`

## Testing Strategy

1. **Unit test modules**: Each module should be importable without errors
2. **VM test x86**: `just test-install pandora` (existing, verify still works)
3. **VM test ARM64**: Use QEMU aarch64 emulation when ARM host is added
4. **Real hardware test**: Flash to USB/SD, boot target machine
