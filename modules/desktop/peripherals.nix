{ pkgs, ... }:
{
  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Scanner support
  hardware.sane.enable = true;

  # USB automounting
  services.udisks2.enable = true;

  # Input devices
  services.libinput.enable = true;
  
  # Additional peripheral packages
  environment.systemPackages = with pkgs; [
    # Audio tools
    pavucontrol
    playerctl
    
    # Bluetooth tools
    bluez-tools
    
    # USB tools
    usbutils
    
    # Input device tools
    libinput
    xorg.xinput
  ];
}