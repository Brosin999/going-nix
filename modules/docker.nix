{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    daemon.settings = {
      runtimes = {
        nvidia = {
          path = "nvidia-container-runtime";
          runtimeArgs = [ ];
        };
      };
    };
  };

  # Add only 'by' user to docker group
  users.groups.docker.members = [ "by" ];
}
