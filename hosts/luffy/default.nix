{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.catppuccin.nixosModules.catppuccin
    "${inputs.self}/modules/desktop"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.luffy = import ../../users/luffy;
    sharedModules = [
      inputs.catppuccin.homeModules.catppuccin
      ./hardware-hyprland.nix
    ];
    extraSpecialArgs = {
      pkgs-unstable = pkgs-unstable;
      inherit inputs;
    };
  };

  users.users.luffy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  networking.hostName = "luffy";
  
  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
