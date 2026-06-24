{ config, pkgs, age, ... }:

{
  services.hermes-agent = {
    enable = true;
    settings = {
      model = {
        default = "gemini-3.5-flash";
        provider = "gemini";
        base_url = "";
      };
      providers = {
        gemini = {
          provider_type = "google";
          api_key_env = "GEMINI_API_KEY"; 
        };
      };
    };
    environmentFiles = [ config.sops.secrets."hermes/env".path ];
    addToSystemPackages = true;
  };
}