# NixOS Configuration Improvements

## Completed

- [x] Fix redundant nixpkgs inputs - now using stable (25.11) + unstable
- [x] Extract hardcoded `x86_64-linux` architecture into a variable
- [x] Add `formatter` output to flake.nix for `nix fmt` support
- [x] Add `devShells` output with linting tools (just, nixfmt-rfc-style, deadnix, statix, typos)
- [x] Make import path style consistent - using `${inputs.self}/...` for cross-directory imports
- [x] Extract duplicate user groups into a shared variable

## Skipped

- [ ] Resolve pandora host - left as-is for future use

## Future Considerations

- [ ] Secrets management (agenix/sops-nix) - password hash currently in version control
- [ ] Consider creating `lib/` directory with helper functions (mkHost, mkHome) as config grows
- [ ] Consider integrating home-manager as NixOS module for single-command updates
