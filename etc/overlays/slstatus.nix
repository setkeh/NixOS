final: prev: {
    slstatus= prev.slstatus.overrideAttrs (oldAttrs: rec {
     /* patches = [
       ./path/to/my-slstatus-patch.patch
       (prev.fetchpatch {
        # replace with actual URL
        url = "";
        # replace hash with the value from `nix-prefetch-url "https://dwm.suckless.org/patches/path/to/patch.diff" | xargs nix hash to-sri --type sha256`
        # or just leave it blank, rebuild, and use the hash value from the error
        sha256 = "";
      })
      ];*/
    configFile = prev.writeText "config.h" (builtins.readFile ../../dotfiles/slstatus/config.h);
    postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
    });
}
