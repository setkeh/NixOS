{ config, lib, osConfig, ... }:
let
  cfg = config.setkeh.backup;
  home = config.home.homeDirectory;
in {
  options.setkeh.backup = {
    enable = lib.mkEnableOption "hourly restic backup of the home directory to the NAS rest-server";

    # The secrets are decrypted by the NixOS sops (host key, owner setkeh): HM sops runs as the
    # user and has no key that can open secrets/<host>.yaml unattended.
    repositoryFile = lib.mkOption {
      type = lib.types.str;
      default = osConfig.sops.secrets."workstation/restic/repository".path;
      description = "File holding the restic repository URL.";
    };
    passwordFile = lib.mkOption {
      type = lib.types.str;
      default = osConfig.sops.secrets."workstation/restic/password".path;
      description = "File holding the restic repository password.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.restic = {
      enable = true;
      backups.nas = {
        inherit (cfg) repositoryFile passwordFile;
        paths = [ home ];

        # Everything here is either backed up some other way or can be rebuilt.
        # Patterns without a slash match that name at any depth.
        exclude = [
          # Every dotfile and dot-directory in ~ (this covers .cache, .steam, Steam and
          # Trash under .local/share, and the 430 GB .bitcoin), except ~/.local/bin, which
          # holds the hand-written MCP scripts. restic can't re-include anything under an
          # excluded directory, so .local is let through and its contents are excluded
          # instead, then .local/bin is negated back in.
          "${home}/.*"
          "!${home}/.local"
          "${home}/.local/*"
          "!${home}/.local/bin"

          "${home}/Downloads"
          "${home}/Development"
          "${home}/Games"
          # Mostly model weights, re-downloadable.
          "${home}/llm-experiments"
          "${home}/ComfyUI"
          "node_modules"
          "target"
          ".direnv"
          "result"
        ];
        extraBackupArgs = [ "--exclude-caches" ];

        # The repository already exists, and the rest-server is private + append-only: this
        # client can add snapshots but never forget or prune them, so pruneOpts stays empty
        # (the module only runs `forget` when it is non-empty).
        initialize = false;
        pruneOpts = [ ];

        timerConfig = {
          OnCalendar = "hourly";
          Persistent = true;
          RandomizedDelaySec = "5m";
        };
      };
    };
  };
}
