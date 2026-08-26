{
  description = "Vocra";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";

    nixos-config = {
      url = "github:setkeh/NixOS";
      inputs.nixpkgs.follows = "nixpkgs"; # dedupe the nixpkgs eval

      # See NOTE [input weight] at the bottom. These follows exist purely to
      # stop `nix develop` on Vocra fetching hermes-agent, claude-desktop,
      # nixos-wsl et al, none of which lib.mkSandbox touches.
      inputs.home-manager.follows = "nixpkgs";
      inputs.sops-nix.follows = "nixpkgs";
    };
  };

  # nixos-config now has to be named here -- it was declared as an input but
  # never threaded into outputs, so it was being fetched and discarded.
  outputs = { self, nixpkgs, utils, nixos-config, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        python = pkgs.python312;

        inherit (nixos-config.lib.mkSandbox { inherit pkgs; }) mkSandbox raw;

        # Single source of truth for the toolchain. Referenced by the plain
        # shell (via buildInputs) and by the sandbox (via packages), so the
        # two cannot drift.
        devTools = [
          # Ai Assistant Packages
          pkgs.uv
          pkgs.nodejs_24
          pkgs.gh

          # Vocra
          python
          pkgs.ruff

          # Sandbox needs these explicitly -- it does not inherit PATH.
          pkgs.bashInteractive
          pkgs.coreutils
          pkgs.git
        ];

        ####################################################################
        # The sandbox itself.
        #
        # stateDir / rwBinds / workDir all use `raw` so they resolve to
        # whatever directory you ran the command from. That is the entire
        # reason this needs sandbox lib v2 -- v1 required eval-time absolute
        # paths, which a devShell cannot know.
        #
        # Visible inside: $PWD, the nix store, the network. Nothing else.
        # Not visible: ~/.config/sops, ~/.gnupg, the gpg-agent socket,
        # ~/.ssh, or any other checkout on the machine.
        ####################################################################
        vocraSandbox = mkSandbox {
          name = "vocra-sandbox";
          packages = devTools;
          command = [ "${pkgs.bashInteractive}/bin/bash" ];

          # Per-checkout state. Add .sandbox/ to .gitignore.
          stateDir = raw ''"$PWD/.sandbox"'';
          rwBinds = [ (raw ''"$PWD"'') ];
          workDir = raw ''"$PWD"'';

          # uv needs to reach PyPI. This is the concession; the filesystem
          # boundary is what is doing the work here.
          network = true;

          # Interactive TTY -- setsid() would detach the controlling
          # terminal and break job control.
          newSession = false;

          keepEnv = [ "TERM" "COLORTERM" "GH_TOKEN" ];

          env = {
            IN_VOCRA_SANDBOX = "1";

            # Same reasoning as the plain shell: uv must not fetch its own
            # interpreter, because downloaded CPython builds expect an FHS
            # dynamic linker.
            UV_PYTHON = "${python}/bin/python3";
            UV_PYTHON_DOWNLOADS = "never";

            # Keep caches inside the checkout. Without this uv writes to
            # $HOME, which here is $PWD/.sandbox -- workable, but explicit
            # is better than incidental.
            UV_CACHE_DIR = raw ''"$PWD/.sandbox/uv"'';
            XDG_CACHE_HOME = raw ''"$PWD/.sandbox/cache"'';

            # git has no global config inside; stop it guessing.
            GIT_CONFIG_GLOBAL = "/dev/null";
          };

          shmSizeGiB = 1;
        };

      in
      {
        ##################################################################
        # Pattern A -- normal shell, sandbox available as a command.
        #
        # Editor, LSP and language servers keep working normally. Run
        # `vocra-sandbox` when you want to execute something you do not
        # fully trust:
        #
        #   $ nix develop
        #   $ vocra-sandbox                    # interactive jailed shell
        #   $ vocra-sandbox -c 'uv run foo.py' # one-shot
        #
        # This is the one to reach for by default.
        ##################################################################
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = devTools ++ [ vocraSandbox ];

          shellHook = ''
            # uv must not fetch its own interpreter: downloaded CPython builds
            # expect an FHS dynamic linker and will not run on NixOS.
            export UV_PYTHON="${python}/bin/python3"
            export UV_PYTHON_DOWNLOADS=never

            echo "--- Vocra Development Environment ---"
            echo "Provided tools:"
            echo "- GH $(gh version | head -1)"
            echo "- Python $(python3 --version)"
            echo "- uv $(uv --version)"
            echo "- ruff $(ruff --version)"
            echo ""
            echo "Sandbox: run 'vocra-sandbox' for a shell jailed to \$PWD."
            echo "         or 'nix develop .#sandboxed' to start inside one."
            echo "----------------------------------------------------"
          '';
        };

        ##################################################################
        # Pattern B -- the shell IS the sandbox.
        #
        #   $ nix develop .#sandboxed
        #
        # CAVEAT: the exec below breaks `nix develop .#sandboxed --command
        # foo`, because the hook replaces the shell before nix gets to run
        # your command. If you need non-interactive use, go through
        # `vocra-sandbox -c '...'` from the default shell instead.
        #
        # CAVEAT 2: your editor and its LSP run OUTSIDE this. A sandboxed
        # shell does not sandbox the pyright your editor spawned.
        ##################################################################
        devShells.sandboxed = pkgs.mkShell {
          buildInputs = [ vocraSandbox ];
          shellHook = ''
            if [ -z "''${IN_VOCRA_SANDBOX:-}" ]; then
              exec ${vocraSandbox}/bin/vocra-sandbox
            fi
          '';
        };

        packages.sandbox = vocraSandbox;
      });
}

/* NOTE [input weight]

   Flake inputs are fetched eagerly. Depending on github:setkeh/NixOS just
   to get one pure function means `nix develop` here pulls hermes-agent,
   claude-desktop, claude-code, lan-mouse, nixos-wsl and sops-nix -- none of
   which mkSandbox references, since it is a plain `pkgs -> attrs` function
   with no nixpkgs pin of its own.

   The follows lines above prune the worst of it, but they are a workaround:
   they make those inputs *wrong* rather than absent, which is only safe
   because nothing in `lib` reads them.

   The clean fix, when you can be bothered: move common/sandbox into its own
   input-free flake (setkeh/nix-sandbox, or a path: subflake inside the
   NixOS repo) and depend on that instead. Zero inputs, instant fetch, and
   the NixOS flake consumes it the same way this one does. Worth doing the
   moment a second project wants it.
*/
