{ self, ... }:
{
	imports = [
		"${self}/modules/base"
		./peripherals.nix
		./desktop.nix
	];
}
