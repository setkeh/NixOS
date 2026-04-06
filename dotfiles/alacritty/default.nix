{
  env = {
    "TERM" = "xterm-256color";
  };

  window.opacity = 0.85;

  window = {
    padding.x = 10;
    padding.y = 10;
    decorations = "none";
  };

  font = { size = 6.0;

    normal.family = "SpaceMono Nerd Font"; #"FuraCode Nerd Font";
    bold.family = "SpaceMono Nerd Font";  #"FuraCode Nerd Font";
    italic.family = "SpaceMono Nerd Font"; #"FuraCode Nerd Font";
  };

  cursor.style = "Beam";

  terminal.shell = {
    program = "fish";
    args = [ "-C neofetch" ];
  };

  colors = {
    # Default colors
    primary = {
      background = "0x1b182c";
      foreground = "0xcbe3e7";
    };

    # Normal colors
    normal = {
      black =   "0x100e23";
      red =     "0xff8080";
      green =   "0x95ffa4";
      yellow =  "0xffe9aa";
      blue =    "0x91ddff";
      magenta = "0xc991e1";
      cyan =    "0xaaffe4";
      white =   "0xcbe3e7";
    };

    # Bright colors
    bright = {
      black =   "0x565575";
      red =     "0xff5458";
      green =   "0x62d196";
      yellow =  "0xffb378";
      blue =    "0x65b2ff";
      magenta = "0x906cff";
      cyan =    "0x63f2f1";
      white = "0xa6b3cc";
    };
  };
}
