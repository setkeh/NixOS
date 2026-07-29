# common/claude-infra/default.nix
#
# Single source of truth for Claude Code across the tightly-coupled
# Terraform (Infrastructure) and Saltstack repos.
#
# Exposed from setkeh/NixOS as `lib.mkClaudeInfra`. Each infra repo's flake
# imports it, passing only its sibling path (the one legitimate per-repo delta).
#
# What this produces:
#   * a shared settings.json   (permissions, hooks, env)  -> --settings
#   * a shared MCP config       (servers; empty for now)  -> --mcp-config
#   * a `claude-infra` launcher that wires both, adds the sibling repo, and
#     (optionally) decrypts MCP secrets via SOPS at launch, then execs Claude.
#
# Because settings + MCP are built from THIS file only, both repos resolve to
# byte-identical /nix/store paths. The sole per-repo difference is the
# `--add-dir` target passed on the command line, so there is nothing to drift.
#
# Also worth Mentioning I use OpenTofu instead of Terraform so all Terraform commands are Adjusted to Tofu.

{ pkgs
, siblingRelPath                # "../Saltstack" or "../Infrastructure"
, mcpSecretsEnv ? null          # path to a SOPS-encrypted dotenv, or null
}:

let
  toJSON = (pkgs.formats.json { }).generate;

  # ---- shared settings (identical in both repos) --------------------------
  # NB: intentionally NO permissions.additionalDirectories here. The sibling is
  # wired via --add-dir in the launcher instead, so this settings file stays
  # identical across both repos (same store path).
  settingsFile = toJSON "claude-settings.json" {
    permissions = {
      allow = [
        "Bash(tofu:*)"
        "Bash(salt:*)"
        "Bash(salt-call:*)"
        "Bash(git:*)"
      ];
      deny = [
        # never let the agent read state or decrypted secret material
        "Read(./**/*.tfstate)"
        "Read(./**/*.tfstate.backup)"
        "Read(./secrets/**)"
      ];
      ask = [
        # confirm anything that mutates real infrastructure
        "Bash(tofu apply:*)"
        "Bash(tofu destroy:*)"
        "Bash(salt * state.apply:*)"
      ];
    };

     hooks = {
       PostToolUse = [
         {
           matcher = "Edit|Write";
           hooks = [
             { type = "command";
               command = "${pkgs.opentofu}/bin/tofu fmt -recursive || true"; }
           ];
         }
       ];
     };

    env = {
      # shared, NON-secret toggles only
    };
  };

  # ---- shared MCP config (identical in both repos) ------------------------
  # No servers yet. When you add one: point `command` at a pinned store path
  # (e.g. a package from setkeh/nixpkgs-channel) rather than npx, and reference
  # any secret by ENV NAME only — the value arrives via the SOPS preamble below.
  mcpFile = toJSON "claude-mcp.json" {
    mcpServers = {
      # Example (commented):
      # some-server = {
      #   command = "${pkgs.some-mcp-server}/bin/some-mcp-server";
      #   args    = [ "--stdio" ];
      #   env     = {
      #     SOME_API_KEY = "$SOME_API_KEY";   # populated by the SOPS preamble
      #   };
      # };
    };
  };

  # ---- optional SOPS preamble --------------------------------------------
  # If an encrypted dotenv is supplied, decrypt it into the environment at
  # launch (via your Yubikey GPG) so values live only in the child process —
  # never on disk, never in the store. Runs decrypt-on-invocation; nothing
  # lingers after the shell exits.
  #sopsPreamble =
  #  if mcpSecretsEnv == null then ""
  #  else ''
  #    set -a
  #    . <(${pkgs.sops}/bin/sops -d --output-type dotenv ${mcpSecretsEnv})
  #    set +a
  #  '';
in
pkgs.writeShellScriptBin "claude-infra" ''
  ${sopsPreamble}
  # load the added (sibling) repo's CLAUDE.md into context too
  export CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1

  exec ${pkgs.claude-code}/bin/claude \
    --settings          ${settingsFile} \
    --mcp-config        ${mcpFile} \
    --strict-mcp-config \
    --add-dir           ${siblingRelPath} \
    "$@"
''