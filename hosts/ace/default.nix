{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}:

{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    "${inputs.self}/modules/desktop"
  ];

  users.users.luffy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialHashedPassword = "$6$TT/n4NMUqmuyQ.GG$Zwv1ZiTeaZheiNAtxu.ybmjrfbKoI2CI/l/xZ7bL3S2uX.jIN4GFV8ZkJ2KIaIWfj5otYkoEFp7/ijnPFvK1v.";
  };

  networking.hostName = "ace";

  # Add your host-specific configuration here
  system.stateVersion = "25.11";
}
