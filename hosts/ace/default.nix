{ config, pkgs, home-manager, self, ... }:

{
  imports = [
    ./hardware-configuration.nix
    home-manager.nixosModules.home-manager
    "${self}/modules/desktop"
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.luffy = import ../../users/luffy;
  };

  users.users.luffy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  networking.hostName = "ace";
  
  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
