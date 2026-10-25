{ pkgs-unstable, ... }:
{
  # Enable Tailscale VPN
  services.tailscale = {
    enable = true;
    package = pkgs-unstable.tailscale;
  };

  # Trust Tailscale interface for incoming connections (allows SSH, etc.)
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
