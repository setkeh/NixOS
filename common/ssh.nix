{ config, pkgs, age, ... }:

{
  programs.ssh = {
    extraConfig = "
      Host mxl-stack-master
        HostName 10.0.134.100  # Replace with the actual IP
        KexAlgorithms +diffie-hellman-group14-sha1,diffie-hellman-group1-sha1
        # You might also need this if it fails on the host key:
        HostKeyAlgorithms +ssh-rsa
    ";
  };
}