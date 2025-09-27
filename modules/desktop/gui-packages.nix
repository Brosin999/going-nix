{ pkgs, ... }:
{
  # Essential GUI applications for desktop environments
  environment.systemPackages = with pkgs; [
    # Terminal emulator
    kitty

    # Web browser
    firefox

    # File manager
    nautilus

    # Application launcher for wayland
    rofi

    # Text editor (GUI)
    # Note: CLI neovim is in base system packages
  ];
}