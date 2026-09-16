{ config, pkgs, lib, ... }:
let
  llamaPackage = pkgs.llama-cpp-rocm;
  models-preset = "${config.xdg.configHome}/llama-cpp/models.ini";
  host = "0.0.0.0";
  port = "8080";
  models-max = "2";

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