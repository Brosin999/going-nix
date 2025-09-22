{ pkgs, ... }:
let
    shellAliases = {
#	l = "eza -l";
#	la = "eza -la";
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
	
	sad # batch file edit
	yq-go # jq for {yaml, json, ini, xml}
	just # command runner (like make)
	hyperfine # benchmark commands
	claude-code # we'll see...

	# networking
	gping # ping with tui graph
	doggo # dns client
	
	# disk mgmnt
	duf # Disk Usage / Free Utility. (df)
	du-dust # Disk Usage (du)

	# nix
	nix-output-monitor # `nom` - nix with better logs
	nix-index # index nix store paths
	nix-melt # tui flake.lock
	nix-tree # tue nix dep tree
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
}
