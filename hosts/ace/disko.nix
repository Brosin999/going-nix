{
  inputs,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "8G"; # adjust to your RAM size / needs
              content = {
                type = "swap";
                randomEncryption = true; # swap gets a fresh random key each boot
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                # omit passwordFile to be prompted for a passphrase during install
                settings = {
                  allowDiscards = true; # good for SSDs
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
