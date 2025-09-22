{ pkgs, ... }:
{
  imports = [
  ];

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

  # Essential Wayland/Hyprland packages
  home.packages = with pkgs; [
    # Wayland utilities
    wl-clipboard      # Clipboard utilities for Wayland
    wlr-randr        # Display configuration tool
    swaybg           # Wallpaper utility
    hyprpicker       # Color picker
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
    
    # Status bar
    waybar           # Highly customizable status bar
    
    # Terminal
    kitty            # GPU-accelerated terminal
    
    # File manager
    nautilus         # GNOME file manager
    
    # Audio
    alsa-utils       # Audio utilities
    networkmanagerapplet  # Network GUI
    
    # Cursor themes
    bibata-cursors   # Modern, clean cursor theme
  ];

  # Enable Hyprland but use traditional config file
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the config file instead of Nix settings
    extraConfig = builtins.readFile ./hyprland.conf;
  };

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

  # Terminal configuration (ryan4yin style)
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono";  # Keep your current font
      font_size = 13;
      background_opacity = "0.93";    # Match ryan4yin's opacity
      
      # Disable audio bell
      enable_audio_bell = false;
      
      # Tab bar at top
      tab_bar_edge = "top";
      
      # Darker theme colors (matching Hyprland blue theme)
      background = "#1a1a1a";
      foreground = "#ffffff";
      selection_background = "#4477ff";
      selection_foreground = "#ffffff";
      cursor = "#4477ff";
      cursor_text_color = "#1a1a1a";
      
      # URL colors
      url_color = "#4477ff";
      url_style = "single";
    };
    
    # Keybindings (ryan4yin style)
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback";
    };
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
