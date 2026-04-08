{ pkgs, lib, ... }: {

  /* Start slstatus */
  systemd.user.services = {
    slstatus = {
      Unit.Description = "Start slstatus on login";
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart = "${pkgs.slstatus}/bin/slstatus";
        Restart = "always";
      };
    };

    agenix = {
      serviceConfig = {
        Environment = "PATH=$PATH:${lib.makeBinPath [ pkgs.age-plugin-yubikey ]}";
      };
    };
  };
}
