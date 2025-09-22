{ ... }:
{
  # home manager info	
  home.username = "luffy";
  home.homeDirectory = "/home/luffy";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  imports = [
    ./common
    ./gui
  ];
}
