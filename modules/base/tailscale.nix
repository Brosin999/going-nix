{ ... }:
{
  # Enable Tailscale VPN
  services.tailscale.enable = true;

  # Trust Tailscale interface for incoming connections (allows SSH, etc.)
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
