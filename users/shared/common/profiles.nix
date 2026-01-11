{ lib, ... }:
{
  options.custom.profiles = {
    development = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable development tools (LSPs, formatters, language toolchains).
        When disabled, use project-specific devShells with direnv instead.
      '';
    };

    tier = lib.mkOption {
      type = lib.types.enum [ "minimal" "standard" "full" ];
      default = "standard";
      description = ''
        Package tier to install:
        - minimal: Core shell utilities only
        - standard: Common tools for daily use (default)
        - full: All tools including heavy/rarely used ones
      '';
    };
  };
}
