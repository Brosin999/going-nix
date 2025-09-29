{ ... }:
{
  # home manager info
  home.username = "by";
  home.homeDirectory = "/home/by";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  imports = [
    ../shared/common
    ../shared/gui
    ./git.nix
  ];
}
