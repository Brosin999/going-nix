default:
	@just --list

[group('nix')]
sw:
	sudo nixos-rebuild switch --flake .#

[group('nix')]
up:
	nix flake update --commit-lock-file

[group('nix')]
fmt:
	nix-shell -p nixfmt-rfc-style deadnix statix typos; nixfmt; deadnix; statix -c; typos; exit;

[group('nix')]
gc:
	nix store gc

[group('nix')]
check:
	nix flake check

[group('nix')]
dry-build:
	nixos-rebuild dry-build --flake .

[group('nix')]
build HOST:
	nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel




