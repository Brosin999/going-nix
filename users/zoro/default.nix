{ inputs, ... }:
{
  home.username = "zoro";
  home.homeDirectory = "/home/zoro";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  custom.profiles.tier = "minimal";

  imports = [
    "${inputs.self}/users/shared/common"
    "${inputs.self}/users/shared/gui"
  ];
}
