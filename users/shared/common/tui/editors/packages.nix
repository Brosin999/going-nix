{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  # Development packages - only installed when custom.profiles.development = true
  # Otherwise, use project devShells with direnv for these tools
  devPackages = with pkgs; [
    # -*- Data & Configuration Languages -*-
    #-- nix
    nil # language server
    nixd # language server
    statix # Lints and suggestions for the nix programming language
    deadnix # Find and remove unused code in .nix source files
    nixfmt-rfc-style # Nix Code Formatter

    #-- nickel lang
    nickel

    #-- json like
    terraform-ls
    jsonnet
    jsonnet-language-server
    taplo # TOML language server / formatter / validator
    nodePackages.yaml-language-server
    actionlint # GitHub Actions linter

    #-- dockerfile
    hadolint # Dockerfile linter
    dockerfile-language-server

    #-- markdown
    marksman # language server for markdown
    glow # markdown previewer
    pandoc # document converter
    pkgs-unstable.hugo # static site generator

    #-- sql
    sqlfluff

    #-- protocol buffer
    buf # linting and formatting

    # -*- General Purpose Languages -*-
    #-- python
    pipx # Install and Run Python Applications in Isolated Environments
    uv # python project package manager
    pyright # python language server
    (python314.withPackages (
      ps: with ps; [
        ruff
        black # python formatter
        jupyter
        ipython
        pandas
        requests
        pyyaml
      ]
    ))

    #-- rust (from unstable for latest toolchain)
    pkgs-unstable.rustc
    pkgs-unstable.rust-analyzer
    pkgs-unstable.cargo
    pkgs-unstable.rustfmt
    pkgs-unstable.clippy

    #-- lua
    stylua
    lua-language-server

    #-- bash
    nodePackages.bash-language-server
    shellcheck
    shfmt

    # -*- Web Development -*-
    nodePackages.nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON/ESLint
    nodePackages."@tailwindcss/language-server"
    emmet-ls

    # -*- Misc -*-
    proselint # English prose linter
    verible # verilog / systemverilog
    nodePackages.prettier # common code formatter
    gdu # disk usage analyzer, required by AstroNvim
  ];

  # Essential packages always installed (minimal set for editor support)
  essentialPackages = [
    pkgs.fzf
    (pkgs.ripgrep.override { withPCRE2 = true; })

    # Core development tools (always needed)
    pkgs.uv # Python package manager
    pkgs-unstable.cargo # Rust package manager (from unstable for latest)
    pkgs-unstable.rustc # Rust compiler (required by cargo)
  ];
in
{
  home.packages = essentialPackages ++ lib.optionals config.custom.profiles.development devPackages;
}
