{ inputs, ... }:
{
  home.username = "luffy";
  home.homeDirectory = "/home/luffy";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
    "${inputs.self}/users/shared/common"
    "${inputs.self}/users/shared/gui"
    ./git.nix
  ];
}
