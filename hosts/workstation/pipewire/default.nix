{ config, lib, pkgs, ... }:

{
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    /* Expose this machine's pipewire-pulse server over TCP so remote clients can tunnel audio into it. */
    extraConfig.pipewire-pulse."30-network-server" = {
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

    /* Wireplumber rules to force correct profile logic */
    wireplumber.extraConfig."51-razer-blackshark-mic" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "device.name" = "~alsa_card.usb-Razer_Razer_BlackShark_V2_HS_2.4*"; }
          ];
          actions = {
            update-props = {
              # Forces both stereo output and mono mic tracking simultaneously 
              "device.profile" = "pro-audio";
              "api.alsa.use-acp" = true; 
            };
          };
        }
      ];
    };
  };
  };

  /* Firewall Rules Scoped to Network not Port */
  networking.firewall.extraInputRules = ''
    ip saddr 10.0.0.0/16 tcp dport 4713 accept
  '';
}