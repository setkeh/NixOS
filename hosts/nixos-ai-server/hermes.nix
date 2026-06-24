{ config, pkgs, age, ... }:

{
  services.hermes-agent = {
    enable = true;
    settings.model.default = "gemini-3.5-flash";
    environmentFiles = [ config.sops.secrets."hermes/env".path ];
    addToSystemPackages = true;
  };
}