{
  description = "NixOS configuration for luffy and ace hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, catppuccin, ... }: {
    nixosConfigurations = {
      luffy = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs; 
          pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux";
        };
        modules = [ ./hosts/luffy ];
      };

      ace = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit inputs; 
          pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux";
        };
        modules = [ ./hosts/ace ];
      };
    };
  };
}