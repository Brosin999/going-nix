{
  description = "NixOS configuration for luffy and ace hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri.url = "github:sodiboo/niri-flake";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      niri,
      disko,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
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

        pandora-installer = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs-unstable;
          };
          modules = [ ./imaging/pandora-installer ];
        };
      };

      homeConfigurations = {
        luffy = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users/luffy
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
            nil
            nixfmt
            nixd
            statix
            deadnix
            typos
            git
          ];
        };
      };
    };
}
