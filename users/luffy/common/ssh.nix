{ ... }:
let
  shellAliases = {
    restart-ssh = "killall ssh-agent; eval `ssh-agent`";
  };
in
{
  # Enable SSH agent service via home-manager
  services.ssh-agent = {
    enable = true;
  };

  # Disable GNOME keyring SSH agent to avoid conflicts  
  services.gnome-keyring = {
    enable = true;
    components = [ "pkcs11" "secrets" ]; # Exclude "ssh" component
  };

  # Shell aliases
  home.shellAliases = shellAliases;
}