{ pkgs, ... }:
{
  # Essential GUI applications for desktop environments
  # Note: User-preference apps (browsers, terminals) are in users/shared/gui/
  environment.systemPackages = with pkgs; [
    # File manager
    nautilus

    # Application launcher for wayland (used by niri Mod+D)
    rofi
  ];
}