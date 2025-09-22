{ pkgs, ... }:
let 
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;
  };

  xdg.configFile."zellij/config.kdl".source = ./config.kdl;

  home.shellAliases = shellAliases;
}
