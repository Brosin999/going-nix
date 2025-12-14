{ inputs, ... }:
{
  imports = [
    "${inputs.self}/modules/base"
    ./peripherals.nix
    ./desktop.nix
    ./gui-packages.nix
    ./niri.nix
    ./gaming.nix
  ];
}
