# llama-cpp from nixos-unstable.
#
# nixos-26.05 ships llama-cpp build 9190, which predates the qwen4exp
# architecture (Qwen3.8-Flash-Next, upstream b10660 / v0.4.0). The unstable
# ROCm build is in cache.nixos.org, so this is a download, not a ROCm compile.
# It links against unstable's own ROCm libraries; that closure is isolated and
# does not replace the ROCm the rest of the system uses.
unstable: final: prev: {
  llama-cpp-rocm = unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.llama-cpp-rocm;
}
