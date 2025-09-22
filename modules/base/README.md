# Host Modules

This directory contains NixOS modules specific to the `luffy` host configuration.

## Modules

- **fonts.nix** - Font configuration
- **system-packages.nix** - System-wide packages
- **nix.nix** - Nix settings and configuration
- **hyprland.nix** - Hyprland window manager setup
- **nvidia.nix** - NVIDIA RTX 3080 GPU configuration

## NVIDIA Commands

After applying the NVIDIA configuration, use these commands to verify and monitor your GPU:

### Check GPU Status
```bash
nvidia-smi
```
Shows GPU information, memory usage, running processes, and driver version.

### Monitor GPU Usage
```bash
nvtop
```
Real-time GPU monitoring with detailed metrics (requires `nvtopPackages.nvidia` package).

### NVIDIA Settings GUI
```bash
nvidia-settings
```
Opens the NVIDIA control panel for advanced configuration.

### Check CUDA Installation
```bash
nvcc --version
```
Verify CUDA toolkit installation (if using CUDA development).

## Rebuilding Configuration

After making changes to any module:

```bash
sudo nixos-rebuild switch
```

For NVIDIA driver changes, a reboot may be required:

```bash
sudo nixos-rebuild switch && sudo reboot
```