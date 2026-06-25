{ config, lib, pkgs, ... }:
{
  virtualisation.docker = {
    enable = true;
    settings = {
      experimental = false;
      logDriver = "json-file";
      defaultUlimits = [
        "name=nofile,value=1024:2048"
      ];
      storageDriver = "overlay2";
    };

    # Common options for all containers
    commonOptions = {
      restartPolicy = "unless-stopped";
      securityOptions = ["no-new-privileges"];
      stopTimeout = "30s";
    };
  };
}