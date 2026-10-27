{ lib, pkgs, ... }:

/* Physical keyboard passthrough for native WayVR windows.

   Builds WayVR with ./wayvr-physical-keyboard.patch (against v26.7.1) and
   has WiVRn launch that build instead of pkgs.wayvr. Import from ./default.nix:
     imports = [ ./wayvr-physical-keyboard.nix ];

   The patch adds no crates and doesn't touch Cargo.lock, so the package's
   cargoHash stays valid. If nixpkgs moves WayVR off 26.7.1 and the patch stops
   applying, the build fails at the patch phase instead of silently dropping it.

   Behaviour (only once enabled, see below):
   - click a native WayVR window with a controller -> physical keyboards are
     grabbed (EVIOCGRAB) and typed into that window; Niri sees nothing
   - click any physical mouse button -> grab released, keys go back to Niri
   - Ctrl+Alt+Escape toggles either way
   If WayVR ever hangs while holding the grab: `pkill wayvr` frees the keyboard.

   Optional physical_mouse (needs physical_keyboard): while a VR window has
   keyboard focus the mouse is grabbed too and drives that window: motion, real
   left/middle/right click (context menus work), scroll wheel. The existing
   cursor dot shows it. A mouse click then no longer returns to the desktop;
   use Ctrl+Alt+Escape.

   Enable it per user, outside WayVR's auto-saved config (which it rewrites):
     ~/.config/wayvr/conf.d/physical-keyboard.json5
       ->  { physical_keyboard: true, physical_mouse: true }
   Check /tmp/wayvr.log for "Physical keyboard passthrough enabled, with mouse". */
let
  wayvrPatched = pkgs.wayvr.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./wayvr-physical-keyboard.patch ];
  });
in
{
  # Matches the list form used in ./default.nix.
  services.wivrn.config.json.application = lib.mkForce [ wayvrPatched ];

  # Reading /dev/input/event* needs the input group (log out and back in after).
  users.users.setkeh.extraGroups = [ "input" ];
}
