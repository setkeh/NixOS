{ config, lib, pkgs, ... }:

{
  /* Expose this machine's pipewire-pulse server over TCP so remote clients can tunnel audio into it. */
  services.pipewire.extraConfig.pipewire-pulse."30-network-server" = {
    "pulse.properties" = {
      "server.address" = [
        "unix:native"
        {
          address = "tcp:4713";
          "max-clients" = 64;
          "listen-backlog" = 32;
          /*
            Network clients default to "restricted", which leaves them waiting
            on WirePlumber for permissions that never arrive — the tunnel
            connects and then does nothing. "unrestricted" is what makes it work.
          */
          "client.access" = "unrestricted";
        }
      ];
    };
  };
  
  /* Firewall Rules Scoped to Network not Port */
  networking.firewall.extraInputRules = ''
    ip saddr 10.0.0.0/16 tcp dport 4713 accept
  '';
}