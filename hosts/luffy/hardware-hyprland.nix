{ ... }:
{
  # Luffy machine specific hardware config for Hyprland
  wayland.windowManager.hyprland.extraConfig = ''
    # Monitor configuration specific to luffy host
    monitor = DP-5, 3840x2160@59.998, 0x0, 1
    monitor = DP-4, 1920x1080@239.75999, 3840x1080, 1

    # Workspace bindings for this monitor setup
    workspace = 1, monitor:DP-5
    workspace = 2, monitor:DP-4
  '';
}