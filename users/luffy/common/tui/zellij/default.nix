{ pkgs, ... }:
let
  shellAliases = {
    "zj" = "zellij";
    "zj-gonix" = "zellij --layout go-nix";
  };
in
{
  programs.zellij = {
    enable = true;
    package = pkgs.zellij;
  };

  xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  xdg.configFile."zellij/layouts/go-nix.kdl".source = ./go-nix.kdl;

  home.shellAliases = shellAliases;
}
