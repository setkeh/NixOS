# Gaming packages taken from nixos-unstable.
#
# umu-launcher: 26.05 ships 1.4.0, which expects exactly two assets on a
# GE-Proton GitHub release. GE-Proton started publishing aarch64 builds
# alongside x86_64 in September 2026, so 1.4.0 discards the listing and Lutris
# installs fail with "Environment variable not set or is empty: PROTONPATH".
# 1.4.4 filters assets by architecture.
unstable: final: prev: {
  umu-launcher = unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.umu-launcher;
}
