{ config, pkgs, pkgs-unstable, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.catppuccin.nixosModules.catppuccin
    "${inputs.self}/modules/desktop"
  ];

  users.users.luffy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  networking.hostName = "luffy";
  
  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
