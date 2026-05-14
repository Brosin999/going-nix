{ ... }:
{
  imports = [
    ./profiles.nix
    ./git.nix
    ./ssh.nix
    # ./theme.nix # Disabled - catppuccin module has compatibility issues
    ./toolbox.nix
    ./tui
    # ./llm.nix
  ];
}
