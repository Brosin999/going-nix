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

# === ISO Generation ===

# Build generic installer ISO with Tailscale (requires auth key)
# Usage: just iso-installer tskey-auth-xxxxx
[group('iso')]
iso-installer tsAuthKey:
	TAILSCALE_AUTH_KEY={{tsAuthKey}} nix build .#nixosConfigurations.installer.config.formats.iso -o result-installer-iso --impure

# Build ISO for specific host (usage: just iso pandora)
[group('iso')]
iso host:
	nix build .#nixosConfigurations.{{host}}.config.formats.iso -o result-{{host}}-iso

# Test any installer in VM (cleans up old VM disk first)
# Usage: just test-vm installer OR just test-vm pandora-installer
[group('iso')]
test-vm config:
	rm -f nixos.qcow2 *.img 2>/dev/null || true
	nix build .#nixosConfigurations.{{config}}.config.formats.vm -o result-{{config}}-vm --impure
	./result-{{config}}-vm/run-nixos-vm

# Build installer ISO with Tailscale + optional notification
# Usage: just iso-install pandora-installer tskey-auth-xxxxx https://ntfy.sh/my-topic
[group('iso')]
iso-install config tsAuthKey notifyUrl="":
	TAILSCALE_AUTH_KEY={{tsAuthKey}} NOTIFY_URL={{notifyUrl}} nix build .#nixosConfigurations.{{config}}.config.formats.iso -o result-{{config}}-iso --impure

# Check closure size for a host (helps estimate disk requirements)
# Usage: just closure-size pandora
[group('profile')]
closure-size host:
	@echo "Checking closure size for {{host}}..."
	@nix path-info -Sh .#nixosConfigurations.{{host}}.config.system.build.toplevel

# Test VM with serial console logged to file (headless, for debugging)
# Output is written to vm-output.log. Use: tail -f vm-output.log
# Usage: just test-vm-log pandora-installer
[group('iso')]
test-vm-log config:
	rm -f nixos.qcow2 *.img vm-output.log 2>/dev/null || true
	nix build .#nixosConfigurations.{{config}}.config.formats.vm -o result-{{config}}-vm --impure
	@echo "Starting VM in headless mode. Serial output -> vm-output.log"
	@echo "Use 'tail -f vm-output.log' in another terminal to watch progress"
	@echo "Press Ctrl+C to stop the VM"
	stdbuf -oL ./result-{{config}}-vm/run-nixos-vm -nographic 2>&1 | tee vm-output.log




