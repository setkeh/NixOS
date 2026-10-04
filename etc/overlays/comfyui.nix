# ComfyUI (ROCm build) from github:utensils/comfyui-nix.
#
# nixpkgs' own `comfyui` hard-wires CUDA 13 torch and the Comfy-Org "ComfyUI
# Desktop" Electron app ships no Linux build, so this flake's `rocm` package is
# the practical option for the 7900 XTX (gfx1100). It bundles ROCm 7.1 in the
# torch wheels; no HSA override, no system ROCm needed.
comfyui-nix: final: prev: {
  comfyui-rocm = comfyui-nix.packages.${prev.stdenv.hostPlatform.system}.rocm;
}
