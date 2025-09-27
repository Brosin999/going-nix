{ ... }:
{
  # Disable all conflicting SSH agents
  services.ssh-agent.enable = false;  # Disable home-manager's ssh-agent

  # Use only GNOME keyring for SSH agent functionality
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" "ssh" ];
  };

  # Remove problematic restart-ssh alias
  home.shellAliases = {};
}