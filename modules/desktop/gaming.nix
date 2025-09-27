{ pkgs, ... }:
{
  # Cachix for nix-gaming to avoid building packages
  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  # Enable OpenGL and 32-bit support for gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Steam and gaming support
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;    # Better resolution scaling and Wayland compatibility
    extest.enable = true;              # X11 input translation for Wayland
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # ProtonGE for better game compatibility
    ];
  };

  programs.gamemode.enable = true;     # Performance optimization for games
  programs.xwayland.enable = true;     # XWayland support (required for many games)

  # Gaming packages
  environment.systemPackages = with pkgs; [
    mangohud    # Performance overlay
    gamemode    # Performance optimization
    steam-run   # Run non-steam games in steam runtime
  ];

  # Low latency audio for gaming (extends existing pipewire config)
  services.pipewire.extraConfig.pipewire."92-low-latency" = {
    context.properties = {
      default.clock.rate = 48000;
      default.clock.quantum = 32;
      default.clock.min-quantum = 32;
      default.clock.max-quantum = 32;
    };
  };
}