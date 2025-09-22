{ config, lib, ... }:
{
	nixpkgs.config.allowUnfree = lib.mkForce true;
	
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
		};
		
		gc = {
			automatic = lib.mkDefault true;
			dates = lib.mkDefault "weekly";
			options = lib.mkDefault "--delete-older-than 7d";
		};

		channel.enable = false; # we use flakes
	};
}	
