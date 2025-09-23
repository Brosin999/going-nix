{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono";
      font_size = 13;
      background_opacity = "0.93";
      
      # Disable audio bell
      enable_audio_bell = false;
      
      # Tab bar at top
      tab_bar_edge = "top";
      
      # Catppuccin Mocha theme
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      selection_background = "#f5e0dc";
      selection_foreground = "#1e1e2e";
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      
      # URL colors
      url_color = "#89b4fa";
      url_style = "single";
      
      # Color palette
      color0 = "#45475a";
      color1 = "#f38ba8";
      color2 = "#a6e3a1";
      color3 = "#f9e2af";
      color4 = "#89b4fa";
      color5 = "#f5c2e7";
      color6 = "#94e2d5";
      color7 = "#bac2de";
      color8 = "#585b70";
      color9 = "#f38ba8";
      color10 = "#a6e3a1";
      color11 = "#f9e2af";
      color12 = "#89b4fa";
      color13 = "#f5c2e7";
      color14 = "#94e2d5";
      color15 = "#a6adc8";
    };
    
    # Keybindings
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback";
    };
  };
}