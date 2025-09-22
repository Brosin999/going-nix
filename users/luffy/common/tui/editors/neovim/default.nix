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
  # Disable catppuccin to avoid conflict with my non-nix config.

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

    # These environment variables are needed to build and run binaries
    # with external package managers like mason.nvim.
    #
    # LD_LIBRARY_PATH is also needed to run the non-FHS binaries downloaded by mason.nvim.
    # it will be set by nix-ld, so we do not need to set it here again.

    # Currently we use lazy.nvim as neovim's package manager, so comment this one.
    #
    # NOTE: These plugins will not be used by astronvim by default!
    # We should install packages that will compile locally or download FHS binaries via Nix!
    # and use lazy.nvim's `dir` option to specify the package directory in nix store.
    # so that these plugins can work on NixOS.
    #
    # related project:
    #  https://github.com/b-src/lazy-nix-helper.nvim
    plugins = with pkgs.vimPlugins; [
      # search all the plugins using https://search.nixos.org/packages
      telescope-fzf-native-nvim

      nvim-treesitter.withAllGrammars
    ];
  };
}
