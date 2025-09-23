{ config, lib, pkgs, inputs, ... }:

let
  # Check if host-specific monitor config exists
  hostName = config.networking.hostName or "unknown";
  hostMonitorConfig = "${inputs.self}/hosts/${hostName}/niri-monitors.kdl";
  hasHostMonitorConfig = builtins.pathExists hostMonitorConfig;

  configContent =
    builtins.readFile ./config.kdl +
    (if hasHostMonitorConfig then "\n" + builtins.readFile hostMonitorConfig else "");
in
{
  imports = [
    ../wayland.nix
    ../alacritty.nix
  ];

  # Use system-provided niri instead of home-manager module
  xdg.configFile."niri/config.kdl".text = configContent;

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