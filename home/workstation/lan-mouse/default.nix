{ config, pkgs, lib, ... }: {
    programs.lan-mouse = {
        enable = true;
        systemd = true;
        settings = { 
            port = 4242;
            clients = [
                {
                  /* "left" | "right" | "top" | "bottom" — the edge of THIS screen you push the pointer through to reach that machine.*/
                  position = "top";
                  hostname = "setkeh-MS-7A34";
                  /* Connect as soon as the daemon starts. */
                  activate_on_startup = true;
                  /* Optional; hostname resolution is used when omitted. */
                  ips = [ "10.0.119.10" "10.0.130.142" ];
                }
            ];
        };
    };

    /* 
        The upstream module only adds the unit to hyprland-session.target
        sway-session.target. niri never matches and the service
        would never be pulled in at login — wire it to graphical-session.target. 
    */
    systemd.user.services.lan-mouse.Install.WantedBy = [ "graphical-session.target" ];
}