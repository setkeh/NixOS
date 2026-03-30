final: prev: {
    dwm = prev.dwm.overrideAttrs (oldAttrs: rec {
      patches = [
      /* ./path/to/my-dwm-patch.patch */

      /* DWM Alpha Patch for Bar Transperancy */ 
      (prev.fetchpatch {
        # replace with actual URL
        url = "https://dwm.suckless.org/patches/alpha/dwm-alpha-20250918-74edc27.diff";
        # replace hash with the value from `nix-prefetch-url "https://dwm.suckless.org/patches/path/to/patch.diff"
        # or just leave it blank, rebuild, and use the hash value from the error
        sha256 = "1q999v0p09c1xs0ryzwjsmds6g0n7p9qr6ji985gf9dx7wg352hz";
      })

      /* Status2d Patch for Bar Color Rendering */
      /* Commenting out for now stats2d seems unmaintained wont patch and i dont have time to fix it right now
      (prev.fetchpatch {
        # replace with actual URL
        url = "https://codeberg.org/justaguylinux/dwm-setup/raw/branch/main/suckless/dwm/patches/dwm-status2d-systray-6.4.diff";
        # replace hash with the value from `nix-prefetch-url "https://dwm.suckless.org/patches/path/to/patch.diff"
        # or just leave it blank, rebuild, and use the hash value from the error
        sha256 = "02gpfrrhhz3zx0xjsj9cpm7lm6m4l8cbwayzwrwfkqcn4wh9gxrd";
      })
      */
      ];
    configFile = prev.writeText "config.h" (builtins.readFile ../../dotfiles/dwm/config.h);
    postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
    });
}
