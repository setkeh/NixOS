{ config, pkgs, lib, ... }:
let
  llamaPackage = pkgs.llama-cpp-rocm;
  models-preset = "${config.xdg.configHome}/llama-cpp/models.ini";
  host = "0.0.0.0";
  port = "8080";
  # One model at a time. Both models fill most of the 24 GB card, and niri shares it: at two, a
  # request for the second model loads it alongside the first instead of swapping, and the GPU
  # runs out of memory (Aegis-AIOS #140).
  models-max = "1";

in {
    systemd.user.services.llama-cpp = {
        Unit = {
            Description = "Llama-cpp service";
        };
        Service = {
            ExecStart = "${pkgs.lib.getExe' llamaPackage "llama-server"} --port ${port} --host ${host} --models-max ${models-max} --models-preset ${models-preset}";
            Restart = "on-failure";
        };
        Install = {
            WantedBy = [ "default.target" ];
        };
    };
}