# Hermes Desktop, and nothing else.
#
# The module comes from inputs.hermes-desktop (see flake.nix, wired in via
# home-manager.sharedModules). Only the application is installed: no
# services.hermes-agent, so no gateway, no backend, no managed config and no
# linger requirement. The launcher still carries HERMES_HOME (~/.hermes).
#
# The remote gateway is configured inside the app: Settings -> Gateways ->
# Remote gateway, URL of the ai-server's `hermes serve`, then sign in. That
# state lives in the app, not here.
{ ... }: {
  programs.hermes-agent.desktop.enable = true;
}
