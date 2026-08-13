{ config, pkgs, lib, ... }: {
    xdg.configFile."niri/config-machine.kdl".source = ./niri/config-machine.kdl;

    xdg.configFile."niri/config.kdl".source =
        pkgs.runCommand "niri-config-checked"
          {
            nativeBuildInputs = [ pkgs.niri ];
          }
          ''
            mkdir -p check
            cp ${../../common/niri/config.kdl} check/config.kdl

            ${lib.optionalString (builtins.pathExists ./niri/config-machine.kdl) ''
              cp ${./niri/config-machine.kdl} check/config-machine.kdl
            ''}

            niri validate --config check/config.kdl
            
            cp check/config.kdl $out

            rm -rf check
          '';

    programs.fuzzel.enable = true; # Super+D in the default setting (app launcher)
    programs.swaylock.enable = true; # Super+Alt+L in the default setting (screen locker)
    services.swayidle.enable = true; # idle management daemon
    services.polkit-gnome.enable = true; # polkit
    home.packages = with pkgs; [
      swaybg # wallpaper
    ];

    xdg.portal.config.niri = {
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ]; # or "kde"
    };
}