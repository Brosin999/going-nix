{ pkgs, ... }:
let
  shellAliases = {
    "y" = "yazi";
  };
in
{
  # imv is now provided by wayland.nix

  # yazi - terminal file manager
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;  # adds 'y' command to cd to yazi's last directory

    settings = {
      manager = {
        show_hidden = true;        # always show hidden files (like .bashrc, .config/)
      };


      opener = {
        edit = [
          { run = "nvim \"$@\""; block = true; for = "unix"; desc = "Edit with Neovim"; }
        ];
        open = [
          { run = "xdg-open \"$@\""; desc = "Open with default app"; for = "unix"; }
        ];
        image = [
          { run = "imv \"$@\""; orphan = true; for = "unix"; desc = "View with imv"; }
          { run = "xdg-open \"$@\""; desc = "Open with default app"; for = "unix"; }
        ];
      };

      open = {
        rules = [
          { mime = "image/*"; use = [ "image" "open" ]; }
          { mime = "text/*"; use = [ "edit" ]; }
          { name = "*"; use = [ "open" ]; }
        ];
      };
    };

    keymap = {
      manager.prepend_keymap = [
        # Press 'Ctrl+s' to search for files by name
        { on = [ "<C-s>" ]; run = "search fd"; desc = "Search files by name"; }
        # Press 'Ctrl+f' to search inside file contents
        { on = [ "<C-f>" ]; run = "search rg"; desc = "Search file contents"; }
        # Press 'e' to edit file with nvim
        { on = [ "e" ]; run = "shell 'nvim \"$1\"' --block --confirm"; desc = "Edit with Neovim"; }
        # Press 'Shift+Y' to copy file to clipboard
        { on = [ "Y" ]; run = "shell 'wl-copy < \"$1\"' --confirm"; desc = "Copy file to clipboard"; }
      ];
    };
  };

  home.shellAliases = shellAliases;
}