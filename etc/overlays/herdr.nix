# herdr from nixos-unstable.
#
# nixos-26.05 doesn't package herdr (terminal workspace manager for AI coding
# agents). The unstable build is in cache.nixos.org, so this is a download.
unstable: final: prev: {
  herdr = unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.herdr;
}
