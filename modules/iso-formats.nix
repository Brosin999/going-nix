# Shared ISO format configuration for per-host builds
# Import this module to enable ISO generation for any host
{ inputs, ... }:
{
  imports = [ inputs.nixos-generators.nixosModules.all-formats ];

  formatConfigs.iso = {
    config,
    lib,
    ...
  }: {
    isoImage.makeEfiBootable = true;
    isoImage.makeUsbBootable = true;
  };
}
