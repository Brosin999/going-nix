{
  inputs,
  lib,
  pkgs,
  modulesPath,
  config,
  ...
}:

let
  # Auth key passed at build time via TAILSCALE_AUTH_KEY environment variable
  tailscaleAuthKey = builtins.getEnv "TAILSCALE_AUTH_KEY";
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    inputs.nixos-generators.nixosModules.all-formats
  ];

  # ISO customization
  formatConfigs.iso = { ... }: {
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
    image.fileName = "going-nix-installer.iso";
  };

  # Bundle flake source into ISO (works with private repos)
  environment.etc."going-nix".source = inputs.self;

  # Symlink to /root for convenience
  system.activationScripts.link-config = ''
    ln -sfn /etc/going-nix /root/going-nix
  '';

  # Network for installation
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;
  networking.firewall.enable = true;

  # Tailscale for remote access
  services.tailscale.enable = true;

  # Auto-authenticate Tailscale on boot
  systemd.services.tailscale-autoconnect = {
    description = "Automatic Tailscale connection";
    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      sleep 2
      status="$(${pkgs.tailscale}/bin/tailscale status -json | ${pkgs.jq}/bin/jq -r .BackendState)"
      if [ "$status" = "NeedsLogin" ]; then
        ${pkgs.tailscale}/bin/tailscale up --authkey ${tailscaleAuthKey}
      fi
    '';
  };

  # SSH over Tailscale only (secure remote installation)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22;
      }
    ];
  };

  # Only allow SSH on Tailscale interface
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 22 ];

  # Installer user with sudo privileges (no root login needed)
  users.users.luffy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keyFiles = [
      "${inputs.self}/users/luffy/id_ed25519.pub"
    ];
  };

  # Allow sudo without password for wheel group (convenient for installation)
  security.sudo.wheelNeedsPassword = false;

  # Auto-login on console for testing/installation convenience
  services.getty.autologinUser = lib.mkForce "luffy";

  # Installation tools
  environment.systemPackages = with pkgs; [
    git
    neovim
    parted
    gptfdisk
    cryptsetup
    btrfs-progs
    dosfstools
    ntfs3g
    jq
  ];

  system.stateVersion = "25.11";
}
