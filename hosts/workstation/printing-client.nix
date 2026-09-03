{ pkgs, ... }:
{
  services.printing.enable = false;

  environment.etc."cups/client.conf".text = ''
    ServerName 10.0.66.75
  '';

  environment.systemPackages = with pkgs; [
    cups          # lp, lpstat, lpoptions, cancel, plus libcups
    glabels-qt    # label designer, optional
  ];
}