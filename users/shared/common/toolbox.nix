{ pkgs, pkgs-unstable, ... }:
let
  shellAliases = {
    #	l = "eza -l";
    #	la = "eza -la";
    "windows" = "sudo efibootmgr --bootnext 0000; sudo reboot";
  };
in
{

  # custom shell aliases for these packages
  programs.bash.enable = true;
  programs.bash.shellAliases = shellAliases;

  home.packages = with pkgs; [
    # important
    cowsay

    # crypto
    gnupg

    # cli tools
    fzf # fuzzy search files
    fd # find file by name (find)
    # search for files by its content, replacement of grep
    (ripgrep.override { withPCRE2 = true; })
    psmisc # provides killall command
    lazygit # terminal ui for git

    sad # batch file edit
    yq-go # jq for {yaml, json, ini, xml}
    just # command runner (like make)
    hyperfine # benchmark commands

    # networking
    gping # ping with tui graph
    doggo # dns client

    # visualization
    graphviz # dot graph visualization
    pastel # command-line tool to work with colors

    # disk mgmnt
    duf # Disk Usage / Free Utility. (df)
    dust # Disk Usage (du)

    # system monitoring
    btop # modern system monitor (top/htop replacement)
    glances # cross-platform system monitoring with web interface
    nload # network load monitoring with real-time traffic visualization
    procs # modern ps replacement with colorful output

    # Files
    yazi # terminal file manager
    pv # better than dd, shows progress of file transfer

    # nix
    nix-output-monitor # `nom` - nix with better logs
    # nix-index provided by nix-index-database module (includes comma for on-demand packages)
    nix-melt # tui flake.lock
    nix-tree # tui nix dep tree

    # misc
    efibootmgr

    # productivity
    taskwarrior3
    pkgs-unstable.opencode
  ];

  # A modern replacement for ‘ls’
  # useful in bash/zsh prompt, not in nushell.
  programs.eza = {
    enable = true;
    # do not enable aliases in nushell!
    enableNushellIntegration = false;
    git = true;
    icons = "auto";
  };

  # a cat(1) clone with syntax highlighting and Git integration.
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
  };

  # very fast version of tldr in Rust
  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };
      updates = {
        auto_update = false;
        auto_update_interval_hours = 720;
      };
    };
  };

  # zoxide is a smarter cd command, inspired by z and autojump.
  # It remembers which directories you use most frequently,
  # so you can "jump" to them in just a few keystrokes.
  # zoxide works on all major shells.
  #
  #   z foo              # cd into highest ranked directory matching foo
  #   z foo bar          # cd into highest ranked directory matching foo and bar
  #   z foo /            # cd into a subdirectory starting with foo
  #
  #   z ~/foo            # z also works like a regular cd command
  #   z foo/             # cd into relative path
  #   z ..               # cd one level up
  #   z -                # cd into previous directory
  #
  #   zi foo             # cd with interactive selection (using fzf)
  #
  #   z foo<SPACE><TAB>  # show interactive completions (zoxide v0.8.0+, bash 4.4+/fish/zsh only)
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
  };

  # direnv - automatically load project environments
  # Use `use flake` in .envrc to load project devShells
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Better caching for nix environments
  };
}
