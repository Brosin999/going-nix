{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
###############################################################################
#
#  AstroNvim's configuration and all its dependencies(lsp, formatter, etc.)
#
#e#############################################################################
let
  shellAliases = {
    v = "nvim";
    vdiff = "nvim -d";
  };
in
{
  xdg.configFile."nvim".source = ./nvim;

  # vim dep
  home.packages = with pkgs; [
    lua
    gcc
    gdb
  ];

  home.shellAliases = shellAliases;
  #  programs.nushell.shellAliases = shellAliases;

  programs.neovim = {
    enable = true;

    # defaultEditor = true; # set EDITOR at system-wide level
    viAlias = true;
    vimAlias = true;
  };
}
