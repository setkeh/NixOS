# Wine for EVE Online / EVE Frontier and other Windows launchers.
#
# - wineWowPackages.waylandFull: Wine 11 with the Wayland driver and 32+64-bit.
# - lutris: has a maintained EVE Frontier installer (slug eve-frontier, wine
#   runner; installs msdelta, arial, tahoma, vcrun2017 into a win64 prefix and
#   downloads the CCP launcher). Lutris manages its own wine-ge runners.
# - umu-launcher: run a Windows launcher under Steam's Proton outside Steam.
# - winetricks: for hand-built prefixes.
# EVE Online is simplest through Steam + Proton (see ../steam).
{ pkgs, ... }: {
  home.packages = with pkgs; [
    wineWowPackages.waylandFull
    winetricks
    lutris
    umu-launcher
  ];
}
