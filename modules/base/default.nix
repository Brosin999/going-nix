{ pkgs, config, ...}:
{
	imports = [
		./fonts.nix
		./system-packages.nix
		./nix.nix
		./hyprland.nix
		./nvidia.nix
		./i18n.nix
		./boot.nix
		./networking.nix
	];
}
