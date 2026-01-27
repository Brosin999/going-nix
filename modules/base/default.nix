{ pkgs, config, ...}:
{
	imports = [
		./fonts.nix
		./system-packages.nix
		./nix.nix
		./nvidia.nix
		./i18n.nix
		./boot.nix
		./networking.nix
		./tailscale.nix
	];
}
