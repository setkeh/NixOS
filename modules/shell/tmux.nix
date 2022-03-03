{pkgs, config, lib, ...}:
with builtins;
with lib;
let
  cfg = config.sys.shell;
in {
  options.sys.shell = {
    tmux = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Tmux for use on this system";
      };
    };
  };

  config = mkIf cfg.tmux.enable {

    # Enable Home Manager Fish Module
    programs.tmux.enable = true;

    imports = [
      ../../dotfiles/tmux/tmux.nix
    ];

  };
}
