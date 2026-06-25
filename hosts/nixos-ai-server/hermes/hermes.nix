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
      api_server = {
        enable = true;
        host = "0.0.0.0";
        port = 9119;
      };
      providers = {
        gemini = {
          provider_type = "google";
          api_key_env = "GEMINI_API_KEY"; 
        };
      };
      honcho = {
        url = "http://localhost:8000";
      };
    };
    
    environmentFiles = [ config.sops.secrets."hermes/env".path ];
    addToSystemPackages = true;

    extraDependencyGroups = [ "honcho" "messaging" ];
    settings.memory.provider = "honcho";

    /*profiles = [
          # Default/orchestrator profile configuration
          ({
            config, pkgs, lib, ...
          }: {
            hermes-agent.profiles = {
              coder = {
                name = "Coder Profile";
                model.default = "mistralai/devstral-small-2-2512";
                model.provider = "lmstudio";
                model.base_url = "http://100.65.62.97:1234/v1";

                toolsets = [ "hermes-cli" "terminal" "file" "code_execution" ];
                agent.personality = "technical";

                # Add coder-specific settings here
              };

              researcher = {
                name = "Researcher Profile";
                model.default = "gemini-3.1-pro-preview";
                toolsets = [ "web" "browser" ];

                # Add researcher-specific settings here
              };
            };
          })
        ];*/
  };
}