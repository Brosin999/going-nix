{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  shellAliases = {
    v = "nvim";
    vdiff = "nvim -d";
  };
in
{

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
    package = pkgs-unstable.neovim-unwrapped;

    # defaultEditor = true; # set EDITOR at system-wide level
    viAlias = true;
    vimAlias = true;

  };

  xdg.configFile."nvim".source = ./nvim;

}
