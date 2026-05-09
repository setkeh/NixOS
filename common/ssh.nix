{ config, pkgs, age, ... }:

{
  programs.ssh = {
    extraConfig = "";
    matchBlocks = {
     "10.0.134.100" = {
       hostname = "10.0.134.100";
       extraOptions = {
         extraConfig = "
           KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
           # You might also need this if it fails on the host key:
           HostKeyAlgorithms +ssh-rsa";
       };
     };
    };
  };
}