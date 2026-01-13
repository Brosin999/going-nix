{
  description = "NixOS configuration for luffy and ace hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    niri.url = "github:sodiboo/niri-flake";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, catppuccin, niri, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        luffy = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [
            ./hosts/luffy
            ./modules/iso-formats.nix
          ];
        };

        ace = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [
            ./hosts/ace
            ./modules/iso-formats.nix
          ];
        };

        pandora = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [
            ./hosts/pandora
            ./modules/iso-formats.nix
          ];
        };

        installer = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [ ./imaging/installer ];
        };
      };

      homeConfigurations = {
        luffy = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users/luffy
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            inherit inputs pkgs-unstable;
          };
        };

        by = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users/by
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            inherit inputs pkgs-unstable;
          };
        };

        zoro = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users/zoro
            inputs.catppuccin.homeModules.catppuccin
            inputs.nix-index-database.homeModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
          ];
          extraSpecialArgs = {
            inherit inputs pkgs-unstable;
          };
        };
      };

      formatter.${system} = pkgs.nixfmt-rfc-style;

      devShells.${system} = {
        # Default shell for this nix config repo
        default = pkgs.mkShell {
          packages = with pkgs; [
            just
            nixfmt-rfc-style
            deadnix
            statix
            typos
          ];
        };

        # Full development environment - use with `nix develop .#dev`
        # or reference from other projects: `nix develop github:by/going-nix#dev`
        dev = pkgs.mkShell {
          packages = with pkgs;
            [
              # Nix tooling
              nil
              nixd
              statix
              deadnix
              nixfmt-rfc-style

              # Python
              pipx
              uv
              pyright
              (python313.withPackages (
                ps: with ps; [
                  ruff
                  black
                  jupyter
                  ipython
                  pandas
                  requests
                  pyyaml
                ]
              ))

              # Rust (from unstable)
              pkgs-unstable.rustc
              pkgs-unstable.rust-analyzer
              pkgs-unstable.cargo
              pkgs-unstable.rustfmt
              pkgs-unstable.clippy

              # Web development
              nodePackages.nodejs
              nodePackages.typescript
              nodePackages.typescript-language-server
              nodePackages.vscode-langservers-extracted
              nodePackages."@tailwindcss/language-server"
              emmet-ls

              # Config languages
              terraform-ls
              jsonnet
              jsonnet-language-server
              taplo
              nodePackages.yaml-language-server
              actionlint

              # Docker
              hadolint
              dockerfile-language-server

              # Markdown/docs
              marksman
              glow
              pandoc
              pkgs-unstable.hugo

              # Shell/scripting
              nodePackages.bash-language-server
              shellcheck
              shfmt
              lua-language-server
              stylua

              # Misc
              nodePackages.prettier
              proselint
              gdu
              fzf
              (ripgrep.override { withPCRE2 = true; })
            ];
        };
      };
    };
}