{ pkgs, ... }:
{
	# sys packages

	# for security reasons, do not load neovim's user config
  	# since EDITOR may be used to edit some critical files
	environment.variables.EDITOR = "nvim --clean";
	
	environment.systemPackages = with pkgs; [
		# core
		tealdeer
		fastfetch
		neovim
		just
		nushell
		git
		git-lfs
		gnugrep

		# compression
		zip
		xz
		zstd

		# networking
		mtr # traceroute + ping
		iperf3 # network benchmark + opt
		dnsutils # dig + nslookup
		wget
		curl
		nmap
		ipcalc
		socat

		# security
		libargon2 # cool hashing
		openssl

		# misc
		file # determine file type
		findutils
		which
		tree
		gnutar
		rsync
	];
}			
