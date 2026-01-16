# Zero-touch installer for pandora
# Boots, connects to Tailscale, and automatically installs NixOS
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
  # Optional notification URL called when installation completes (e.g., ntfy.sh topic)
  # Example: NOTIFY_URL="https://ntfy.sh/my-pandora-install"
  notifyUrl = builtins.getEnv "NOTIFY_URL";
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
    image.fileName = "pandora-installer.iso";
  };

  # VM customization (for testing) - add second disk for installation target
  formatConfigs.vm = { ... }: {
    virtualisation.memorySize = 4096;  # 4GB RAM (enough for evaluation)
    virtualisation.cores = 4;
    # Boot disk needs space for downloading packages during installation
    # (pandora closure is 12GB, plus temp space for builds and nix store overhead)
    virtualisation.diskSize = 40960;  # 40GB boot disk
    # Use disk-backed store instead of tmpfs (tmpfs limited by RAM, disk is larger)
    virtualisation.writableStoreUseTmpfs = false;
    # Add a second disk that the installer will target (instead of the boot disk)
    virtualisation.emptyDiskImages = [ 30720 ];  # 30GB second disk at /dev/vdb
  };

  # Bundle flake source into ISO (works with private repos)
  environment.etc."going-nix".source = inputs.self;

  # Symlink for convenience
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

  # Auto-install service - runs after Tailscale connects
  systemd.services.auto-install-pandora = {
    description = "Automatic NixOS installation for pandora";
    after = [
      "tailscale-autoconnect.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "journal+console";
      StandardError = "journal+console";
    };
    path = with pkgs; [
      util-linux
      coreutils
      gnugrep
      gptfdisk  # for sgdisk (wipe partition table)
      disko
      nixos-install-tools
      curl
    ];
    script = ''
      set -euo pipefail

      # Tee all output to serial console (/dev/ttyS0) for headless VM debugging
      # while keeping normal console output for physical display
      exec > >(tee /dev/ttyS0) 2>&1

      echo ""
      echo "========================================"
      echo "  PANDORA AUTO-INSTALLER"
      echo "========================================"
      echo ""

      # Find target disk (prefer NVMe, then secondary virtio disk for VM testing)
      TARGET_DISK=""
      for disk in /dev/nvme0n1 /dev/nvme1n1 /dev/sda /dev/vdb /dev/vda; do
        if [ -b "$disk" ]; then
          TARGET_DISK="$disk"
          break
        fi
      done

      if [ -z "$TARGET_DISK" ]; then
        echo "ERROR: No suitable disk found!"
        echo "Available block devices:"
        lsblk
        exit 1
      fi

      echo "Target disk: $TARGET_DISK"
      echo ""

      # Show disk info
      echo "Disk information:"
      lsblk "$TARGET_DISK"
      echo ""

      # Safety countdown - gives time to abort
      echo "!!! WARNING: This will ERASE ALL DATA on $TARGET_DISK !!!"
      echo ""
      echo "Installation will begin in 30 seconds..."
      echo "Press Ctrl+C or power off to abort."
      echo ""

      for i in $(seq 30 -1 1); do
        echo -ne "\rStarting in $i seconds...  "
        sleep 1
      done
      echo ""
      echo ""

      echo "Starting installation..."
      echo ""

      # Wipe existing partition table (handles re-runs on already-partitioned disks)
      echo "Wiping partition table on $TARGET_DISK..."
      wipefs -af "$TARGET_DISK" || true
      sgdisk --zap-all "$TARGET_DISK" || true

      # Run disko-install (handles partitioning via --mode format)
      ${pkgs.disko}/bin/disko-install \
        --flake "/etc/going-nix#pandora" \
        --disk main "$TARGET_DISK"

      echo ""
      echo "========================================"
      echo "  INSTALLATION COMPLETE!"
      echo "========================================"
      echo ""

      # Send notification if URL configured
      NOTIFY_URL="${notifyUrl}"
      if [ -n "$NOTIFY_URL" ]; then
        echo "Sending completion notification..."
        curl -sf -X POST "$NOTIFY_URL" \
          -H "Title: Pandora Installation Complete" \
          -H "Priority: high" \
          -H "Tags: white_check_mark" \
          -d "NixOS installation on pandora completed successfully. System will reboot now." \
          || echo "Warning: Failed to send notification"
      fi

      echo "System will reboot in 10 seconds..."
      echo "Remove the installation media before reboot."
      echo ""

      sleep 10
      systemctl reboot
    '';
  };

  # SSH over Tailscale only (secure remote access)
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

  # Installer user with sudo privileges
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

  # Allow sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Auto-login on console for local monitoring
  services.getty.autologinUser = lib.mkForce "luffy";

  # Disable serial getty so it doesn't interfere with installer output logging
  systemd.services."serial-getty@ttyS0".enable = false;

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
    disko
  ];

  system.stateVersion = "25.11";
}
