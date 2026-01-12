{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

let
  defaultGroups = [
    "wheel"
    "networkmanager"
    "ollama"
    "wireshark"
    "video"
  ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.catppuccin.nixosModules.catppuccin
    "${inputs.self}/modules/desktop"
    "${inputs.self}/modules/docker.nix"
  ];

  users.users.luffy = {
    isNormalUser = true;
    extraGroups = defaultGroups;
  };

  users.users.by = {
    isNormalUser = true;
    extraGroups = defaultGroups;
    initialHashedPassword = "$y$j9T$v5gsLt.9MHUYYcLEzA/Rd/$aYWKCBKXHfgWXTV5Glhm7GZIR9z.J82MwvpGbJCY3x1";
  };

  networking.hostName = "luffy";

  # NVIDIA GPU configuration
  hardware.nvidia-custom.enable = true;

  # VirtualBox host support
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "luffy" "by" ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
