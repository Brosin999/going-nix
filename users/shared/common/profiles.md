# Profile Options

This module provides options to control which packages are installed, allowing for minimal initial builds while maintaining access to tools when needed.

## Available Options

### `custom.profiles.development`

**Type:** `boolean`
**Default:** `false`

When enabled, installs all development tools (LSPs, formatters, language toolchains). When disabled, these tools are available via:
- Project devShells with direnv
- On-demand with comma (`, rustc --version`)
- The full dev environment (`nix develop .#dev`)

**Packages included when enabled:**
- **Nix:** nil, nixd, statix, deadnix, nixfmt-rfc-style
- **Python:** python313, pyright, uv, pipx, jupyter, pandas
- **Rust:** rustc, rust-analyzer, cargo, rustfmt, clippy (from unstable)
- **Web:** nodejs, typescript, typescript-language-server, tailwindcss-language-server
- **Config:** terraform-ls, jsonnet, taplo, yaml-language-server, actionlint
- **Docker:** hadolint, dockerfile-language-server
- **Docs:** marksman, glow, pandoc, hugo
- **Shell:** bash-language-server, shellcheck, shfmt
- **Lua:** lua-language-server, stylua
- **Misc:** prettier, proselint, verible

### `custom.profiles.tier`

**Type:** `enum [ "minimal" "standard" "full" ]`
**Default:** `"standard"`

Controls the base package tier (currently used for future expansion).

## Usage

### Enable development tools for a user

```nix
# users/by/default.nix
{ inputs, ... }:
{
  home.username = "by";
  home.homeDirectory = "/home/by";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Enable development profile
  custom.profiles.development = true;

  imports = [
    "${inputs.self}/users/shared/common"
    "${inputs.self}/users/shared/gui"
  ];
}
```

### Use project-specific devShells instead

For most workflows, keeping `development = false` and using project devShells is recommended:

```bash
# In your project directory
echo "use flake" > .envrc
direnv allow
```

Create a `flake.nix` in your project:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs = { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          rustc cargo rust-analyzer  # Only what this project needs
        ];
      };
    };
}
```

### Use the full dev environment from this repo

```bash
# From any directory
nix develop github:by/going-nix#dev

# Or locally
nix develop /home/by/going-nix#dev
```

## On-Demand Packages with Comma

Run any package without installation:

```bash
, cowsay "Hello"           # Run cowsay temporarily
, ffmpeg -i video.mp4      # Use ffmpeg without installing
, htop                     # Quick system monitoring
, jq '.key' file.json      # Process JSON once
```

This uses nix-index-database to find and run packages from nixpkgs.

## Build Time Analysis

Check what will be built before switching:

```bash
# See derivations to build vs fetch
nix build --dry-run .#homeConfigurations.by.activationPackage

# Interactive dependency browser
nix-tree ./result

# Profile evaluation time
NIX_SHOW_STATS=1 home-manager build
```
