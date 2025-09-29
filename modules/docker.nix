{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Add only 'by' user to docker group
  users.groups.docker.members = [ "by" ];
}