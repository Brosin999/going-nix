{ pkgs, ... }:
{
  # Essential session variables for Wayland
  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # for any ozone-based browser & electron apps to run on wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # for firefox to run on wayland
    "MOZ_WEBRENDER" = "1";
    # enable native Wayland support for most Electron apps
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
    # misc
    "_JAVA_AWT_WM_NONREPARENTING" = "1";
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1";
    "QT_QPA_PLATFORM" = "wayland";
    "SDL_VIDEODRIVER" = "wayland";
    "GDK_BACKEND" = "wayland";
    "XDG_SESSION_TYPE" = "wayland";
  };

  # Essential Wayland packages
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard      # Clipboard utilities for Wayland
    wlr-randr        # Display configuration tool
    swaybg           # Wallpaper utility
    brightnessctl    # Brightness control
    
    # Screenshot and screen recording
    grim             # Screenshot utility
    slurp            # Screen area selection
    swappy           # Screenshot annotation
    wf-recorder      # Screen recording
    
    # Application launcher and menu
    rofi             # Application launcher
    
    # Notification daemon
    mako             # Lightweight notification daemon
    
    # Status bar managed by home-manager programs.waybar
    
    # File manager
    nautilus         # GNOME file manager

    # Image viewer
    imv              # Wayland image viewer
    
    # Audio
    alsa-utils       # Audio utilities
    pamixer          # Pulseaudio command line mixer
    easyeffects      # Modern audio effects and mixer
    # helvum         # Graph-based PipeWire patchbay (interesting for future)
    networkmanagerapplet  # Network GUI
    
    # Cursor themes
    bibata-cursors   # Modern, clean cursor theme
  ];

  # Configure related services
  services = {
    # Notification daemon
    mako = {
      enable = true;
      settings = {
        background-color = "#1e1e2e";
        border-color = "#89b4fa";
        border-radius = 10;
        border-size = 2;
        text-color = "#cdd6f4";
        default-timeout = 5000;
      };
    };
  };

  # Waybar configuration
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = (builtins.fromJSON (builtins.readFile ./waybar/config.jsonc));
    };
    style = builtins.readFile ./waybar/style.css;
  };

  # Cursor theme configuration
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}