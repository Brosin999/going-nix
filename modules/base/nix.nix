{ config, lib, ... }:
{
	nixpkgs.config.allowUnfree = lib.mkForce true;
	
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
			substituters = [
				"https://cache.nixos.org"
				"https://niri.cachix.org"
			];
			trusted-public-keys = [
				"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
				"niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
			];
		};
		
		gc = {
			automatic = lib.mkDefault true;
			dates = lib.mkDefault "weekly";
			options = lib.mkDefault "--delete-older-than 7d";
		};

		channel.enable = false; # we use flakes
	};
}	
