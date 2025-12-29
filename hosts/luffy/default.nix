{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.catppuccin.nixosModules.catppuccin
    "${inputs.self}/modules/desktop"
    "${inputs.self}/modules/docker.nix"
    "${inputs.self}/modules/base/ai-nvidia.nix"
  ];

  users.users.luffy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "ollama"
    ];
  };

  users.users.by = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "ollama"
    ];
    initialHashedPassword = "$y$j9T$v5gsLt.9MHUYYcLEzA/Rd/$aYWKCBKXHfgWXTV5Glhm7GZIR9z.J82MwvpGbJCY3x1";
  };

  networking.hostName = "luffy";

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
