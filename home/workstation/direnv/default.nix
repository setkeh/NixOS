{ config, pkgs, lib, ... }: {
    programs = {
    direnv = {
      enable = true;
      #enableBashIntegration = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };

    #bash.enable = true;
    fish.enable = true;
  };
}