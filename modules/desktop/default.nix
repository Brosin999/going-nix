{ inputs, ... }:
{
	imports = [
		"${inputs.self}/modules/base"
		./peripherals.nix
		./desktop.nix
	];
}
