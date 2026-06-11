{ ... }:

{
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true; # provides `docker` CLI alias
    defaultNetwork.settings.dns_enabled = true;
  };
}
