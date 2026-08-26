/* common/sandbox/default.nix  -- v2

   Changes from v1, both additive and backwards compatible:

     raw      -- marker for values resolved at RUNTIME rather than eval time.
                 `raw ''"$PWD"''` lets a devShell jail itself to whatever
                 directory it was entered from, which v1 could not express
                 because every path went through escapeShellArg.

     keepEnv  -- env var names forwarded from the caller's environment if
                 (and only if) they are set. Emitted AFTER the eval-time
                 --setenv args, so keepEnv wins on collision.

   Exposed as flake.lib.mkSandbox so project flakes can consume it:
     lib.mkSandbox = import ./common/sandbox;
*/
{ pkgs
, lib ? pkgs.lib
}:

let
  gib = n: n * 1024 * 1024 * 1024;

  ##########################################################################
  # raw: escape hatch for values the shell must resolve at runtime.
  #
  #   raw ''"$PWD"''      -> emitted verbatim, expands in the wrapper
  #   "/home/setkeh/src"  -> escapeShellArg'd, cannot expand
  #
  # You own the quoting inside a raw value. Quote it.
  ##########################################################################
  raw = s: { __raw = s; };

  isRaw = a: builtins.isAttrs a && a ? __raw;

  renderArg = a:
    if isRaw a then a.__raw
    else lib.escapeShellArg (toString a);

  renderArgs = args: lib.concatStringsSep " " (map renderArg args);

  normalise = e:
    if isRaw e then { src = e; dest = e; }
    else if builtins.isAttrs e && e ? src then { src = e.src; dest = e.dest or e.src; }
    else { src = e; dest = e; };

  bindArgs = flag: entries:
    lib.concatMap (e: let b = normalise e; in [ flag b.src b.dest ]) entries;

  mkSandbox =
    { name
    , command
    , packages ? [ ]
    , rwBinds ? [ ]
    , roBinds ? [ ]
    , devBinds ? [ ]
    , stateDir
    , tmpfsPaths ? [ ]
    , shmSizeGiB ? 2
    , network ? false
    , env ? { }

      # Names only. Forwarded at runtime if set in the caller's environment.
      # Typical: [ "TERM" "COLORTERM" "GH_TOKEN" ]
      #
      # Do NOT add "PATH" unless you mean it -- PATH is built from `packages`
      # so sandbox contents are deterministic rather than dependent on how
      # you happened to enter the shell.
    , keepEnv ? [ ]

    , newSession ? true
    , workDir ? null
    , extraBwrapArgs ? [ ]
    }:

    let
      shmBytes = toString (gib shmSizeGiB);
      cwd = if workDir == null then stateDir else workDir;

      baseEnv = {
        HOME = stateDir;
        TMPDIR = "/tmp";
        PATH = lib.makeBinPath (packages ++ [ pkgs.coreutils ]);
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      } // env;

      envArgs = lib.concatLists
        (lib.mapAttrsToList (k: v: [ "--setenv" k v ]) baseEnv);

      hostDirs = [ stateDir ] ++ (map (e: (normalise e).src) rwBinds);

      bwrapArgs =
        [ "--unshare-all" ]
        ++ (lib.optional network "--share-net")
        ++ [ "--die-with-parent" "--clearenv" ]
        ++ (lib.optional newSession "--new-session")
        ++ [ "--hostname" name ]

        ++ [ "--ro-bind" "/nix/store" "/nix/store" ]
        ++ [ "--proc" "/proc" ]
        ++ [ "--dev" "/dev" ]

        # --dev only mkdir()s /dev/shm inside the /dev tmpfs. Mount a real,
        # explicitly-sized tmpfs over it so the limit is known.
        ++ [ "--size" shmBytes "--tmpfs" "/dev/shm" ]

        ++ [ "--tmpfs" "/tmp" ]
        ++ (lib.concatMap (p: [ "--tmpfs" p ]) tmpfsPaths)

        ++ [ "--ro-bind-try" "/run/opengl-driver" "/run/opengl-driver" ]
        ++ [ "--ro-bind-try" "/run/opengl-driver-32" "/run/opengl-driver-32" ]

        ++ (lib.optionals network [
          "--ro-bind-try" "/etc/resolv.conf" "/etc/resolv.conf"
          "--ro-bind-try" "/etc/hosts" "/etc/hosts"
        ])
        ++ [ "--ro-bind-try" "/etc/passwd" "/etc/passwd" ]
        ++ [ "--ro-bind-try" "/etc/group" "/etc/group" ]

        ++ (bindArgs "--ro-bind" roBinds)
        ++ [ "--bind" stateDir stateDir ]
        ++ (bindArgs "--bind" rwBinds)
        ++ (lib.concatMap (d: [ "--dev-bind-try" d d ]) devBinds)

        ++ envArgs
        ++ [ "--chdir" cwd ]
        ++ extraBwrapArgs;

      keepEnvBlock = lib.optionalString (keepEnv != [ ]) ''
        for _v in ${lib.escapeShellArgs keepEnv}; do
          if [ -n "''${!_v+x}" ]; then
            _keep+=( --setenv "$_v" "''${!_v}" )
          fi
        done
      '';

    in
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.bubblewrap pkgs.coreutils ];
      text = ''
        mkdir -p ${renderArgs hostDirs}

        _keep=()
        ${keepEnvBlock}

        exec bwrap \
          ${renderArgs bwrapArgs} \
          "''${_keep[@]}" \
          -- ${renderArgs command} "$@"
      '';
    };

in
{
  inherit mkSandbox raw gib;
}

/* NOTES

   Nesting.
   --------
   bwrap inside bwrap works -- the kernel allows nested user namespaces to a
   depth of 32 -- so a sandboxed Claude Code session can still enter a
   sandboxed devShell. What does not survive is the outer bind list: the
   inner sandbox only sees paths the outer one already exposed. A confusing
   ENOENT on a bind source is almost always this.

   No network half-measures.
   -------------------------
   Still honest none/host. The slirp4netns + CONNECT-proxy recipe is in the
   v1 notes; it needs --info-fd and child-pid parsing and is a separate
   piece of work rather than a wrapper flag.

   Escape surfaces, ranked.
   ------------------------
   1. devBinds -- /dev/kvm and /dev/kfd are direct kernel interfaces.
   2. The kernel itself. Namespace jail, shared kernel. Untrusted firmware
      still belongs in QEMU without KVM, or a real VM.
   3. /dev/shm is not one. tmpfs, not a device node, private per sandbox.
      The realistic failure is filling it, which is why it is sized.

   No resource accounting.
   -----------------------
   bubblewrap does none. For caps:
     systemd-run --user --scope -p MemoryMax=32G -- <wrapper>
*/
