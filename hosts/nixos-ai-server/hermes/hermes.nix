{ config, pkgs, lib, age, ... }: # Ensure 'lib' is available here for lib.cleanSourceWith and lib.any

let
  # Define the list of skill categories/directories you want to DISABLE
  # These should be the names of the directories under your Hermes skills path.
  # If a skill is in a subdirectory (e.g., 'research/research-paper-writing'),
  # list the full relative path.
  skillsToDisable = [
    "smart-home"
    "social-media"
    "yuanbao"
    "media"
    "creative"
    "email"
    "mlops"
    "data-science"
    "dogfood"
    "apple" # Disables all Apple/macOS-specific skills
    "research/research-paper-writing" # Disables the large LaTeX templates
    "productivity" # Disables all skills under the productivity category
    "note-taking/obsidian" # Disables Obsidian-specific note-taking
    "autonomous-ai-agents/claude-code" # Disables specific autonomous agents
    "autonomous-ai-agents/codex"
    "autonomous-ai-agents/opencode"
    # Add any other skill categories/directories you wish to disable here
  ];

  # A function to filter out unwanted skill directories from the bundled skills source
  filterSkills = oldAttrs: {
    # The `bundledSkills` attribute in hermes-agent.nix is what we want to override.
    # We create a filtered source based on the original Hermes Agent's source path.
    bundledSkills = lib.cleanSourceWith {
      # Assuming hermes-agent's skills are located directly in a 'skills' subdirectory
      # relative to its main source. Adjust 'src = "${oldAttrs.src}/skills";' if needed.
      src = "${oldAttrs.src}/skills";
      filter = path: type:
        let
          # Get the relative path of the item within the skills directory.
          # We need 'toString oldAttrs.src' to correctly remove the prefix.
          skillsRoot = "${toString oldAttrs.src}/skills";
          relativePath = lib.removePrefix "${skillsRoot}/" (toString path);
          # Check if the relative path starts with any of the skills to disable.
          # This handles both top-level directories and nested ones.
          shouldDisable = lib.any (s: lib.hasPrefix s relativePath) skillsToDisable;
        in
        # Keep items that should NOT be disabled, and also apply the original filter
        # to exclude things like index-cache files.
        !shouldDisable && !(lib.hasInfix "/index-cache/" path);
    };
  };

  # Create a custom hermes-agent package by overriding its attributes with our filter.
  # This makes our filtered skills the 'bundledSkills' for our specific Hermes Agent instance.
  myHermesAgent = pkgs.hermes-agent.overrideAttrs filterSkills;

in
{
  networking.firewall.allowedTCPPorts = [
    9119 # Hermes Dashboard
  ];

  services.hermes-agent = {
    enable = true;
    
    # Assign our custom-filtered Hermes Agent package to the service.
    package = myHermesAgent;

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
        provider = "gemini";
        model = "gemini-2.5-pro"; # This model is for the orchestrator (Aegis)
        #provider = "novita";
        #default = "deepseek/deepseek-v4-pro";
        #base_url = "https://api.novita.ai/openai/v1";
      };
      agent = {
        reasoning_effort = "low";
        notification_sources = [ "*" ];
        # Consolidated list of toolsets to disable for the orchestrator.
        # This will reduce the prompt size significantly.
        disabled_toolsets = [
          "web"               # High token schema, often not needed for orchestration
          "browser"           # High token schema, not typically used by orchestrator
          "image_gen"         # Not for orchestration
          "tts"               # Text-to-speech, not for orchestration
          "computer_use"      # Not for orchestration (e.g., desktop automation)
          "vision"            # Image analysis, not for orchestration
          "feishu_doc"        # Feishu tools, not for general orchestration
          "feishu_drive"      # Feishu tools, not for general orchestration
          "messaging"         # Review if truly not needed for cron delivery / notifications
          "video"             # Not for orchestration
          "video_gen"         # Not for orchestration
          "homeassistant"     # Smart home, not for orchestration
          "x_search"          # X (Twitter) search, not for orchestration
          "context_engine"    # Specialized context engine, disable if not explicitly used
          "spotify"           # Not for orchestration
          "yuanbao"           # Not for orchestration
        ];
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
        }
        {
          provider = "novita";
          model = "qwen/qwen3.5-397b-a17b";
        }
      ];

      honcho = {
        enable = true;
        apiKey = ""; # Assuming this is set via environmentFiles/secrets
        url = "http://127.0.0.1:8000";
      };
      compression = {
        enabled = true;
        threshold = 0.50;      # Compresses when context is 50% full
        target_ratio = 0.20;   # Compresses down to 20% size
        protect_last_n = 5;   # Keeps the most recent 5 messages uncompressed
      };
    };

    environmentFiles = [ config.sops.secrets."hermes/env".path ];
    addToSystemPackages = true;

    extraDependencyGroups = [ "honcho" "messaging" ]; # Keep messaging if needed for cron delivery
    settings.memory.provider = "honcho";

    profiles = [
          # Default/orchestrator profile configuration
          # Note: The 'profiles' block here defines *other* profiles (coder, researcher)
          # not the main Aegis orchestrator itself. The 'settings' above apply to Aegis.
          ({
            config, pkgs, lib, ...
          }: {hermes-agent.profiles = {
              coder = {
                name = "Coder Profile";
                model.default = "mistralai/devstral-small-2-2512";
                model.provider = "lmstudio";
                model.base_url = "http://100.65.62.97:1234/v1";

                # Coder profile's toolsets should be specialized.
                # Ensure these match what the coder truly needs and no more.
                toolsets = [ "hermes-cli" "terminal" "file" "code_execution" ];
                agent.personality = "technical";
                agent.disabled_toolsets = [
                  "web" # Coder might need web for research, review this
                  "browser"
                  "vision"
                  "image_gen"
                  "tts"
                  "computer_use"
                  "feishu_doc"
                  "feishu_drive"
                  "messaging"
                  "video"
                  "video_gen"
                  "homeassistant"
                  "x_search"
                  "context_engine"
                  "spotify"
                  "yuanbao"
                  "skills" # Coder probably doesn't need to manage skills
                  "todo" # Coder has its own todo list usually, but can keep if needed for self-management
                  "memory" # Coder might have its own memory, depends on config
                  "session_search"
                  "clarify"
                  "delegation" # Coder should be a leaf, not delegating further
                  "cronjob"
                ];
                # Add coder-specific settings here
              };

              researcher = {
                name = "Researcher Profile";
                model.default = "gemini-3.1-pro-preview";
                # Researcher profile's toolsets should be specialized.
                # Ensure these match what the researcher truly needs and no more.
                toolsets = [ "web" "browser" "file" "search" ]; # Added 'file' for reading local data
                agent.disabled_toolsets = [
                  "terminal" # Researcher typically doesn't need terminal for general research
                  "code_execution"
                  "vision"
                  "image_gen"
                  "tts"
                  "computer_use"
                  "feishu_doc"
                  "feishu_drive"
                  "messaging"
                  "video"
                  "video_gen"
                  "homeassistant"
                  "x_search"
                  "context_engine"
                  "spotify"
                  "yuanbao"
                  "skills" # Researcher probably doesn't need to manage skills
                  "todo"
                  "memory"
                  "session_search"
                  "clarify"
                  "delegation" # Researcher should be a leaf
                  "cronjob"
                ];
                # Add researcher-specific settings here
              };
            };
          })
        ];
  };
}