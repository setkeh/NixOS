{ config, pkgs, lib, ... }:

let
  sandboxLib = import ../../../common/sandbox { inherit pkgs lib; };
  inherit (sandboxLib) mkSandbox;

  home = config.home.homeDirectory;
  state = "${home}/.local/state/sandbox/ollama";

  ollama = mkSandbox {
    name = "ollama-sandbox";
    packages = [ pkgs.ollama-rocm ];
    command = [ "${pkgs.ollama-rocm}/bin/ollama" ];
    stateDir = "${state}/ollama";
    rwBinds = [ "${home}/.ollama" ];
    devBinds = [ "/dev/kfd" "/dev/dri" ];
    network = true;
    newSession = true;

    # ROCm and llama.cpp both lean on /dev/shm for buffer handoff between
    # the userspace driver and the compute process. 8 GiB is generous; drop
    # it if you would rather find the real floor empirically.
    shmSizeGiB = 8;

    env = {
      OLLAMA_MODELS = "${home}/.ollama/models";
      OLLAMA_HOST = "127.0.0.1:11434";

      # gfx1100 (7900 XTX) is natively supported by ROCm -- this override is
      # for gfx1101/1102 (7800/7700 XT) and is a no-op
      # HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };
  };
in
{
  home.packages = [
    ollama
  ];
}