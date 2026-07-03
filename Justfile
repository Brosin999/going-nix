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

# Garbage collect nix store (default: delete older than 7d, use 0d to delete all)
[group('nix')]
gc age="7d":
	sudo nix-collect-garbage --delete-older-than {{age}}
	nix-collect-garbage --delete-older-than {{age}}
	@echo "Done. Current store size:"
	@duf /nix/store

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

# === Claude Agent Container ===

# Claude Code is installed via the native installer (auto-updates to latest in
# the persistent claude-home volume) -- no version to pin. After (re)building,
# run `just claude-agent-clean` once if you have an old npm-based claude-home
# volume, so a fresh volume picks up the native install.
# Build the sandboxed Claude Code agent container image
[group('claude-agent')]
claude-agent-build:
	cd imaging/claude-agent && podman build --build-arg DEV_UID=$(id -u) -t claude-agent:latest .

# Full rebuild: clear cached layers, volume, and rebuild from scratch
[group('claude-agent')]
claude-agent-rebuild:
	-podman volume rm claude-home
	cd imaging/claude-agent && podman build --no-cache --build-arg DEV_UID=$(id -u) -t claude-agent:latest .
	@echo "Rebuilt from scratch. claude-home volume cleared (re-auth needed)."

# Test that srt's nested bubblewrap sandbox works inside the container
[group('claude-agent')]
claude-agent-test:
	@mkdir -p /tmp/claude-agent-test
	podman run --rm --entrypoint /bin/bash --device nvidia.com/gpu=all \
		--security-opt=label=disable --group-add keep-groups --userns=keep-id \
		-v /tmp/claude-agent-test:/home/dev/project:rw \
		-v $(pwd)/imaging/claude-agent/srt-settings.json:/home/dev/.srt-settings.json:ro \
		localhost/claude-agent:latest \
		-c 'srt --settings ~/.srt-settings.json echo ok'
	@rm -rf /tmp/claude-agent-test

# Usage: just claude-agent-run ~/my-project
# Disable the inner srt sandbox (Layer 2) for unrestricted network + simpler
# startup while getting going:  USE_SRT=0 just claude-agent-run ~/my-project
# (Layer 1 — the hardened container — still isolates the host.)
# Interactive use is subscription-login (OAuth), NOT an API key: no
# ANTHROPIC_API_KEY is forwarded. On first run, Claude prints a login URL —
# open it in your own browser and paste the code back. The token persists in
# the claude-home volume, so you only log in once.
# Run Claude Code interactively in the sandboxed container
[group('claude-agent')]
claude-agent-run project_path:
	podman run --rm -it --log-level=debug --device nvidia.com/gpu=all \
		--security-opt=label=disable --group-add keep-groups --userns=keep-id \
		--cap-drop=ALL --security-opt=no-new-privileges \
		-e USE_SRT \
		-v claude-home:/home/dev \
		-v $(pwd)/imaging/claude-agent/srt-settings.json:/home/dev/.srt-settings.json:ro \
		-v {{project_path}}:/home/dev/project:rw \
		localhost/claude-agent:latest

# Shell into the container for debugging
[group('claude-agent')]
claude-agent-shell project_path="/tmp":
	podman run --rm -it --entrypoint /bin/bash --device nvidia.com/gpu=all \
		--security-opt=label=disable --group-add keep-groups --userns=keep-id \
		-v claude-home:/home/dev \
		-v $(pwd)/imaging/claude-agent/srt-settings.json:/home/dev/.srt-settings.json:ro \
		-v {{project_path}}:/home/dev/project:rw \
		localhost/claude-agent:latest

# Remove the claude-home volume (clears cached state, auth tokens, nix store)
# -f force-removes the volume even when exited/leftover containers still
# reference it (it stops/removes those containers first, with a grace period).
# Without -f, a plain `volume rm` fails with "volume is being used" and the
# volume survives -- so this recipe would lie about having removed it.
[group('claude-agent')]
claude-agent-clean:
	-podman volume rm -f claude-home
	@echo "claude-home volume removed. Next run will re-initialize."

# Store API key as a podman secret (for Quadlet service use)
# Usage: just claude-agent-secret sk-ant-...
[group('claude-agent')]
claude-agent-secret key:
	printf '%s' "{{key}}" | podman secret create anthropic-api-key -

# Install the Quadlet systemd service for autonomous operation
[group('claude-agent')]
claude-agent-install:
	mkdir -p ~/.config/containers/systemd
	cp imaging/claude-agent/claude-agent.container ~/.config/containers/systemd/
	systemctl --user daemon-reload
	@echo "Installed. Start with: systemctl --user start claude-agent"
	@echo "Logs: journalctl --user -u claude-agent -f"
