# NixOS
NixOS Configuration and Dotfiles Repo

## Allow Unfree
By default Nix does not allow installing Software with Unfree Licenses, To enable this there is `./user/nixpkgs.nix`.

If you have issues on first `home-manager switch` with non free errors you may need to use the envirnoment variable for the first run `NIXPKGS_ALLOW_UNFREE=1 home-manager switch` after the first run and the config.nix is setup you will not need this again.
