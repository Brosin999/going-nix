{ pkgs, ... }:
{
  imports = [
    ../wayland.nix
    ../alacritty.nix
  ];

  # Use system-provided niri instead of home-manager module
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  home.file.".wayland-session" = {
    source = pkgs.writeScript "init-session" ''
      # trying to stop a previous niri session
      systemctl --user is-active niri.service && systemctl --user stop niri.service
      # and then we start a new one
      /run/current-system/sw/bin/niri-session
    '';
    executable = true;
  };

  xdg.desktopEntries.niri = {
    name = "Niri";
    comment = "A scrollable-tiling Wayland compositor";
    exec = "niri-session";
    type = "Application";
    categories = [ "System" ];
    noDisplay = false;
  };
}