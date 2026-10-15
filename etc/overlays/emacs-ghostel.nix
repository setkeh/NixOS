# ghostel, the terminal backend claude-code-ide recommends, plus its Evil
# integration, built from nixos-unstable's ghostel recipe (0.52.0) but against
# our own Emacs and toolchain. Only the recipe comes from unstable; the build
# uses this system's Emacs and Zig 0.16.
#
# 26.05 packages a May 2026 ghostel snapshot and no evil-ghostel at all;
# evil-ghostel 0.52.0 requires ghostel 0.52.0.
#
# Exposed as functions of an Emacs package set, so Doom's package set
# (common/applications/doom-emacs) builds them for the Emacs it uses.
unstable: final: prev:
let
  ghostelFor =
    epkgs:
    epkgs.callPackage "${unstable}/pkgs/applications/editors/emacs/elisp-packages/manual-packages/ghostel/package.nix" { };
in
{
  inherit ghostelFor;

  # Lives in ghostel's repo; built from the same source so the versions match.
  evilGhostelFor =
    epkgs:
    let
      ghostel = ghostelFor epkgs;
    in
    epkgs.trivialBuild {
      pname = "evil-ghostel";
      inherit (ghostel) version;
      src = "${ghostel.src}/extensions/evil-ghostel";
      packageRequires = [
        epkgs.evil
        ghostel
      ];
    };
}
