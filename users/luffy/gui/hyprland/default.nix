{ pkgs, ... }:
{
  imports = [
    ../wayland.nix
    ../kitty.nix
  ];

  # Hyprland-specific packages
  home.packages = with pkgs; [
    hyprpicker       # Color picker
  ];

  # Enable Hyprland but use traditional config file
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the config file instead of Nix settings
    extraConfig = builtins.readFile ./hyprland.conf;
  };

}
