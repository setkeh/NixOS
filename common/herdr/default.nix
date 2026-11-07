{ config, lib, pkgs, ... }:

# herdr: persistent terminal workspaces for AI coding agents (pkgs.herdr comes
# from etc/overlays/herdr.nix). config.toml is managed here, so it is read-only:
# changes made in herdr's settings screen won't save, put them in `settings`.
# `herdr --default-config` prints every option with its default.
let
  toml = pkgs.formats.toml { };
in {
  home.packages = [ pkgs.herdr ];

  xdg.configFile."herdr/config.toml".source = toml.generate "herdr-config.toml" {
    # Notifications are chosen below, and the file can't be written to record
    # that onboarding was done.
    onboarding = false;

    terminal = {
      # The login shell is bash; panes should get fish like the terminals do.
      default_shell = "/etc/profiles/per-user/setkeh/bin/fish";
    };

    update = {
      # Nix owns the binary, so `herdr update` and its nag can't apply here.
      version_check = false;
    };

    ui.toast = {
      # In-app toasts when an agent in another workspace finishes or needs input.
      delivery = "herdr";
    };
  };
}
