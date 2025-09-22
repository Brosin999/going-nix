{ ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable display manager and desktop environments
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;  # Keep GNOME as fallback option

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}