{config, pkgs, ...}:

{
  nixpkgs.overlays = [
    (self: super: {
      dwm = super.dwm.overrideAttrs (oldAttrs: rec {
#        patches = [
#        ./path/to/my-dwm-patch.patch
#        ];
      configFile = super.writeText "config.h" (builtins.readFile ../../dotfiles/dwm/config.h);
      postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
    })
  ];
}
