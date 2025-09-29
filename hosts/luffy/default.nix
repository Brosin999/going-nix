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

  users.users.by = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialHashedPassword = "$y$j9T$v5gsLt.9MHUYYcLEzA/Rd/$aYWKCBKXHfgWXTV5Glhm7GZIR9z.J82MwvpGbJCY3x1";
  };

  networking.hostName = "luffy";
  
  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
