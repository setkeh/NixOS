# OpenRazer taken from nixos-unstable.
#
# openrazer: 26.05 ships 3.12.3, whose kernel driver calls strncpy(). Linux 7.2
# no longer provides it, so the module fails to build. 3.12.4 switched to
# strscpy(). The driver is still built against our own kernel; only the
# version and source come from unstable, and the daemon/library are bumped to
# match it.
unstable: final: prev:
let
  u = unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
in
{
  linuxPackages_latest = prev.linuxPackages_latest.extend (kfinal: kprev: {
    openrazer = kprev.openrazer.overrideAttrs (_: {
      version = "${u.python3Packages.openrazer.version}-${kprev.kernel.version}";
      inherit (u.linuxPackages_latest.openrazer) src;
    });
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      openrazer = pyprev.openrazer.overridePythonAttrs (_: {
        inherit (u.python3Packages.openrazer) version src;
      });
      openrazer-daemon = pyprev.openrazer-daemon.overridePythonAttrs (_: {
        inherit (u.python3Packages.openrazer-daemon) version src;
      });
    })
  ];
}
