{ pkgs, ... }:
{
  services.printing.enable = false;

  environment.etc = {
    "cups/client.conf".text = ''
        ServerName 10.0.66.75
    '';

    /* Setting lpoptions for posteck label printer */
    "cups/lpoptions".text = ''
        Dest labels media-type=labels
        Dest labels-red media-type=labels media-top-offset=400
    '';
  };

  environment.systemPackages = with pkgs; [
    cups          # lp, lpstat, lpoptions, cancel, plus libcups
  ];
}