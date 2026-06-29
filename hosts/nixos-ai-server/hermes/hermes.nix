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
        tools = {
          # Specify ONLY the tools you want Hermes to have access to
          include = [
            "list_workspaces"
            "get_workspace"
            "create_doc"
            "read_doc"
            "list_docs"
            "get_doc"
            "search_docs"
            "update_doc_title"
            "append_markdown"
            "list_organize_nodes"
            "create_folder"
          ];
        };
      };
    };

    settings = {
      model = {
        provider = "novita";
        default = "deepseek/deepseek-v4-pro";
        base_url = "https://api.novita.ai/openai/v1";
      };
      agent = {
        reasoning_effort = "low";
      };
      providers = {
        gemini = {
          provider_type = "google";
          api_key_env = "GEMINI_API_KEY"; 
        };
        novita = {
          provider_type = "novita";
        };
      };
      fallback_providers = [
        {
          provider = "gemini";
          model = "gemini-2.5-flash";
        },
        {
          provider = "novita";
          model = "qwen/qwen3.5-397b-a17b";
        }
      ];

      honcho = {
        enable = true;
        apiKey = "";
        url = "http://127.0.0.1:8000";
      };
      compression = {
        enabled = true;
        threshold = 0.50;      # Compresses when context is 50% full
        target_ratio = 0.20;   # Compresses down to 20% size
        protect_last_n = 15;   # Keeps the most recent 15 messages uncompressed
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