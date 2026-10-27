# NDI 6 SDK at the version NDI currently serves.
#
# NDI publishes the SDK at an unversioned URL, so the file changes under the package: 26.05 pins
# 6.3.1.0 and its hash fails since NDI shipped 6.3.2. Only the version and hash move here (same
# values as nixos-unstable's version.json); the build stays on 26.05's libraries, since libndi is
# loaded into the OBS process. Drop this once 26.05 catches up, or bump it when NDI ships again.
final: prev: {
  ndi-6 = prev.ndi-6.overrideAttrs (old: {
    version = "6.3.2.0";
    src = prev.fetchurl {
      inherit (old.src) url;
      hash = "sha256-8DFPJFRG3vxIi2POtGiazxqWWu79ray3BXG7IWqMwYM=";
    };
  });
}
