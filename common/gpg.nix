{ config, lib, pkgs, ... }:

{
  # GPG Yubikey & SSH
  services.pcscd.enable = true;
  hardware.gpgSmartcards.enable = true;

  programs.ssh.startAgent = false;
  
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gtk2; #pkgs.pinentry-curses;
    enableExtraSocket = true;
  };
}
