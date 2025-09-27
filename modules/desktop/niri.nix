{ inputs, pkgs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  programs.niri.enable = true;
  programs.niri.package = pkgs.niri;

  # Desktop portals for screen sharing
  xdg.portal = {
    enable = true;
    config.niri = {
      default = ["gnome" "gtk"];
      "org.freedesktop.impl.portal.Access" = "gtk";
      "org.freedesktop.impl.portal.Notification" = "gtk";
      "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.portal.ScreenCast" = "gnome";
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}