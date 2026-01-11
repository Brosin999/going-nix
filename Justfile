default:
	@just --list

# === Build & Switch ===

[group('nix')]
sw:
	sudo nixos-rebuild switch --flake .#

[group('nix')]
hm:
	home-manager switch --flake .#$USER

[group('nix')]
up:
	nix flake update --commit-lock-file

[group('nix')]
check:
	nix flake check

[group('nix')]
gc:
	nix store gc

[group('nix')]
fmt:
	nix fmt

# === Profiling & Analysis ===

# Preview what will be built (no actual build)
[group('profile')]
dry:
	nixos-rebuild dry-build --flake .

# Preview home-manager build
[group('profile')]
dry-hm:
	nix build --dry-run .#homeConfigurations.$USER.activationPackage

# Build system and compare with current (shows package changes)
[group('profile')]
diff-system:
	nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel -o /tmp/new-system
	nix store diff-closures /run/current-system /tmp/new-system

# Build home-manager and compare with current
[group('profile')]
diff-hm:
	nix build .#homeConfigurations.$USER.activationPackage -o /tmp/new-hm
	nix store diff-closures ~/.local/state/nix/profiles/home-manager /tmp/new-hm

# Show closure sizes for current system
[group('profile')]
sizes:
	nix path-info -rsSh /run/current-system | sort -hk2 | tail -30

# Show closure sizes for home-manager
[group('profile')]
sizes-hm:
	nix path-info -rsSh ~/.local/state/nix/profiles/home-manager | sort -hk2 | tail -30

# Interactive dependency browser for system
[group('profile')]
tree:
	nix-tree /run/current-system

# Interactive dependency browser for home-manager
[group('profile')]
tree-hm:
	nix-tree ~/.local/state/nix/profiles/home-manager

# Why does system depend on a package? Usage: just why-depends rustc
[group('profile')]
why-depends PKG:
	nix why-depends /run/current-system nixpkgs#{{PKG}}

# Switch with verbose output through nom
[group('profile')]
sw-verbose:
	sudo nixos-rebuild switch --flake .# -L 2>&1 | nom

# Home-manager switch with verbose output
[group('profile')]
hm-verbose:
	home-manager switch --flake .#$USER 2>&1 | nom

# Show evaluation statistics
[group('profile')]
eval-stats:
	NIX_SHOW_STATS=1 nix build .#nixosConfigurations.$(hostname).config.system.build.toplevel --dry-run 2>&1 | head -100




