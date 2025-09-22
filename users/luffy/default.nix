{ config, pkgs, ... }:

{
  home = {
    username = "luffy";
    homeDirectory = "/home/luffy";
    stateVersion = "25.11";
  };

  programs = {
    home-manager.enable = true;
    
    # Add your user-specific programs here
    # bash.enable = true;
    # git = {
    #   enable = true;
    #   userName = "luffy";
    #   userEmail = "luffy@example.com";
    # };
  };

  # Add your dotfiles and user-specific configuration here
}
