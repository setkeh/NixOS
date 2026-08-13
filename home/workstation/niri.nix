{ config, pkgs, lib, ... }: {
    #xdg.configFile."niri/config.kdl".source = ../../common/niri/config.kdl;
    xdg.configFile."niri/config-machine.kdl".source = ./niri/config-machine.kdl;

    xdg.configFile."niri/config.kdl".source =
        pkgs.runCommand "niri-config-checked"
          {
            nativeBuildInputs = [ pkgs.niri ];
          }
          ''
            niri validate --config ${../../common/niri/config.kdl}
            cp ${../../common/niri/config.kdl} $out
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