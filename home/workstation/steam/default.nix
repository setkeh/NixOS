# Steam, user side.
#
# `steam` itself comes from the NixOS module (`programs.steam` in
# hosts/workstation): it needs the FHS environment, 32-bit graphics, udev rules
# and the Proton compat-tool wiring, none of which Home Manager can provide.
# This module adds the tools that live in the user's session.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    protonup-qt        # install/update Proton-GE builds per user, pick per game
    mangohud           # FPS/frametime overlay (MANGOHUD=1 or launch option)
    gamescope          # micro-compositor for games that misbehave on Wayland
    # xwayland-satellite (X11 bridge for Steam/Wine under Niri) is in packages.nix
  ];
}
