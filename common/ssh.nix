{ config, pkgs, age, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Clears the default config deprecation warning

    settings = {
      # Global defaults (applied to all hosts)
      "*" = {
        AddKeysToAgent = "no";
        Compression = "no";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        ForwardAgent = "no";
        HashKnownHosts = "no";
        ServerAliveCountMax = 3;
        ServerAliveInterval = 0;
        UserKnownHostsFile = "~/.ssh/known_hosts";
      };

      # Your legacy server block
      "10.0.134.100" = {
        HostName = "10.0.134.100";
        KexAlgorithms = "+diffie-hellman-group14-sha1,diffie-hellman-group1-sha1";
        HostKeyAlgorithms = "+ssh-rsa";
      };

      # Your AI Server block with the YubiKey tunnel
      "Ai-Server" = {
        HostName = "10.0.66.75";
        User = "setkeh";
        ForwardAgent = true;
        RemoteForward = "/run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra";
      };
    };
  };
}
