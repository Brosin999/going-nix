{ ... }:
{

  # System-level Hyprland enablement - minimal setup for NixOS
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Enable Xwayland for X11 app compatibility
  };

  # Essential system services for Wayland
  services.dbus.enable = true;
  
  # XDG desktop portal for proper app integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
