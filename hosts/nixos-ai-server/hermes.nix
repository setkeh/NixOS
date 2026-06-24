{ config, pkgs, lib, ... }:

let
  # Grab the standard Nix YAML generator
  yaml = pkgs.formats.yaml { };

  # Define your worker profiles in a standard Nix attribute set
  profiles = {
    coder = {
      # This description is critical: It is what Kanban reads to route tasks
      description = "Expert software engineer. Writes and refactors code.";
      settings = {
        model.default = "anthropic/claude-sonnet-4";
        # You can add toolsets, mcp_servers, etc. here just like the main service
      };
      envFile = config.sops.secrets."hermes-coder-env".path;
    };
    
    researcher = {
      description = "Reads source code and external docs, writes findings.";
      settings = {
        model.default = "anthropic/claude-opus-4.6";
      };
      envFile = config.sops.secrets."hermes-researcher-env".path;
    };
  };

in {
  # 1. The Default Profile (The Orchestrator)
  services.hermes-agent = {
    enable = true;
    settings.model.default = "anthropic/claude-sonnet-4";
    environmentFiles = [ config.sops.secrets."hermes-orchestrator-env".path ];
    addToSystemPackages = true;
  };

  # 2. Declaratively inject the worker profiles into the Hermes state directory
  systemd.tmpfiles.rules = lib.flatten (lib.mapAttrsToList (name: profile: let
    
    # Generate immutable YAML files in the Nix store for each profile
    configYaml = yaml.generate "hermes-${name}-config.yaml" profile.settings;
    profileYaml = yaml.generate "hermes-${name}-profile.yaml" { description = profile.description; };
    
  in [
    # Ensure the profile directory exists and is owned by the hermes daemon
    "d /var/lib/hermes/profiles/${name} 0770 hermes hermes - -"
    
    # Force symlink (L+) the Nix-generated configs into the profile directory
    "L+ /var/lib/hermes/profiles/${name}/config.yaml - - - - ${configYaml}"
    "L+ /var/lib/hermes/profiles/${name}/profile.yaml - - - - ${profileYaml}"
    
    # Symlink the SOPS secret directly as the profile's .env file
    "L+ /var/lib/hermes/profiles/${name}/.env - - - - ${profile.envFile}"
    
  ]) profiles);
}