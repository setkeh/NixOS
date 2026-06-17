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

     "10.0.66.75" = {
        hostname = "10.0.66.75";
        user = "setkeh";
        forwardAgent = true;
        extraOptions = {
          # Maps your local extra socket to the remote regular socket
          RemoteForward = "/run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra";
        };
      };
     };
    };
  };
}