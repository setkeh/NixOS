{ config, pkgs, lib, ... }: {
    services.mako = {
    enable = true;
    settings = {
      # Global settings
      anchor = "top-right";
      font = "JetBrainsMono Nerd Font 10";
      background-color = "#282a36";
      text-color = "#f8f8f2";
      border-color = "#bd93f9";
      border-size = 2;
      border-radius = 6;
      max-icon-size = 48;
      margin = "10";
      padding = "10";
      default-timeout = 5000; # 5 seconds

      # Context-specific section example (e.g. urgent notifications)
      "urgency=high" = {
        border-color = "#ff5555";
        default-timeout = 0; # persistent until clicked
      };
    };
  };
}