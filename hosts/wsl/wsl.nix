{ config, lib, pkgs, ... }:

{
  wsl = {
    enable = true;
    defaultUser = "setkeh";
    usbip = {
      enable = true;
      # Replace this with the BUSID for your Yubikey
      autoAttach = ["10-1"];
    };
  };
}
