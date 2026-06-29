{ config, pkgs, age, ... }:

{
  networking.firewall.allowedTCPPorts = [ 
    9119 # Hermes Dashboard
  ];
  
  services.hermes-agent = {
    enable = true;

    # 1. Inject API call tuning variables here
    environment = {
      # Extends the timeout window for a single payload to finish processing
      HERMES_API_TIMEOUT = "120"; 
      
      # Sets the base delay multiplier for retry logic (default is usually ~2-5s)
      HERMES_RETRY_BASE_DELAY = "15"; 
      
      # Caps the maximum delay between backoff retries so it doesn't scale to infinity
      HERMES_RETRY_MAX_DELAY = "60"; 
    };

    mcpServers = {
      affine = {
        url = "http://10.20.16.242:3000/mcp";
        headers.Authorization = "Bearer \${AFFINE_MCP_BEARER}";
      };
    };

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
        enable = true;
        apiKey = "";
        url = "http://127.0.0.1:8000";
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