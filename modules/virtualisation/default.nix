{pkgs, lib, config, ...}:
with lib;
let
  cfg = config.sys.virtualisation;
  cpuType = config.sys.cpu.type;

in {
  options.sys.virtualisation = {
    kvm = {
      enable = mkEnableOption "Enable KVM";
    };

    docker = {
      enable = mkEnableOption "Enable Docker";
    };
  };

  config = {
    virtualisation.libvirtd.enable = cfg.kvm.enable;
    virtualisation.docker.enable = cfg.docker.enable;

    boot.kernelModules = [
      (mkIf (cpuType == "amd") "kvm-amd")
      (mkIf (cpuType == "intel") "intel-amd")
    ];
  };
}
