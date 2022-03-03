{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  fileSystems."/" = {
      device = "/dev/disk/by-uuid/...";
      fsType = "ext4";
    };

  fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/...";
      fsType = "vfat";
    };

  swapDevices =[{
    device = "/dev/disk/by-uuid/...";
  }];
}
