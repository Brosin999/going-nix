{ inputs, ... }:
{
  home.username = "by";
  home.homeDirectory = "/home/by";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
    "${inputs.self}/users/shared/common"
    "${inputs.self}/users/shared/gui"
    ./stoken.nix
  ];
}
