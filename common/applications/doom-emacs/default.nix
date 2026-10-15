{ config, pkgs, ... }:

/* Doom Emacs, built entirely in Nix by nix-doom-emacs-unstraightened from ./doom
   (init.el, config.el, packages.el). There is no `doom sync`: Doom and every
   package are built at switch time, and edits to ./doom take effect on the next
   rebuild. The host's home-manager.sharedModules must include
   inputs.nix-doom-emacs-unstraightened.homeModule.

   Provides `emacs` and `emacsclient`. */
{
  programs.doom-emacs = {
    enable = true;
    doomDir = ./doom;
    emacs = pkgs.emacs-pgtk; # native Wayland

    # Language servers for the +lsp modules in init.el, on Doom's PATH only.
    extraBinPackages = with pkgs; [
      ripgrep
      fd
      git
      gopls                                 # (go +lsp)
      nil                                   # (nix +lsp)
      rust-analyzer                         # (rust +lsp)
      terraform-ls                          # (terraform +lsp)
      python3Packages.jedi-language-server  # (python +lsp), via lsp-jedi
      bash-language-server                  # (sh +fish +lsp)
      shellcheck                            # :checkers syntax for shell scripts
    ];
  };
}
