{ pkgs, pkgs-unstable, config, ... }:
let
  repoBase = "/home/${config.home.username}/going-nix/users/shared/gui/vscode";
in
{
  home.packages = [
    pkgs-unstable.vscode
  ];

  # Mutable symlinks pointing directly at the repo checkout
  home.file.".config/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${repoBase}/settings.json";
  home.file.".config/Code/User/keybindings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${repoBase}/keybindings.json";
}
