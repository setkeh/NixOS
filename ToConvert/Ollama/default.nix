/* common/sandbox/default.nix

   Bubblewrap sandbox generator, in the same shape as lib.mkClaudeInfra:
   imported into flake.lib, called from a home-manager module.

     mkSandbox = import ./common/sandbox;
     ...
     (inputs.self.lib.mkSandbox { inherit pkgs; }).mkSandbox { name = "..."; ... }

   Every path passed in must be an ABSOLUTE, EVAL-TIME path. Do not pass
   "$HOME/..." -- pass "${config.home.homeDirectory}/..." so the generated
   script can be shell-escaped safely.

   System-side prerequisites (see hosts/workstation/sandbox.nix):
     - unprivileged user namespaces enabled (NixOS default)
     - pkgs.bubblewrap available
     - user in the "render" group for /dev/kfd, "kvm" for /dev/kvm
*/
{ pkgs
, lib ? pkgs.lib
}:

let
  gib = n: n * 1024 * 1024 * 1024;

  # Accept either "/path" or { src = "/a"; dest = "/b"; }
  normalise = e:
    if builtins.isString e
    then { src = e; dest = e; }
    else { src = e.src; dest = e.dest or e.src; };

  bindArgs = flag: entries:
    lib.concatMap
      (e: let b = normalise e; in [ flag b.src b.dest ])
      entries;

  mkSandbox =
    { name

      # Command to run inside. A list: [ "${pkgs.foo}/bin/foo" "--flag" ]
      # "$@" from the wrapper is always appended.
    , command

      # Packages whose /bin lands on PATH inside the sandbox.
    , packages ? [ ]

      # Writable binds. Created on the host if missing.
    , rwBinds ? [ ]

      # Read-only binds.
    , roBinds ? [ ]

      # Device binds (--dev-bind-try). These are HOLES. Keep the list short.
      # e.g. [ "/dev/kfd" "/dev/dri" ] for ROCm, [ "/dev/kvm" ] for QEMU.
    , devBinds ? [ ]

      # Per-sandbox persistent state. Becomes $HOME inside.
    , stateDir

      # Extra tmpfs mounts beyond /tmp.
    , tmpfsPaths ? [ ]

      # /dev/shm sizing. ROCm and torch are the usual reasons to raise this.
    , shmSizeGiB ? 2

      # false  -> --unshare-all, loopback only, no route out at all.
      # true   -> --share-net, full host network access.
      # There is deliberately no half-measure here; see NOTES at the bottom.
    , network ? false

      # Extra environment. PATH/HOME/TMPDIR are set for you.
    , env ? { }

      # setsid(). Blocks TIOCSTI injection (CVE-2017-5226) but detaches the
      # controlling terminal -- job control and Ctrl-C behave differently.
      # Leave true for daemons; set false for interactive TTY programs.
    , newSession ? true

      # Working directory inside the sandbox. Defaults to stateDir.
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
        # /etc/ssl on NixOS is a symlink farm into /etc/static; pointing at the
        # store path directly avoids needing to bind either.
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      } // env;

      envArgs = lib.concatLists
        (lib.mapAttrsToList (k: v: [ "--setenv" k (toString v) ]) baseEnv);

      # Directories that must exist on the host before bwrap binds them.
      hostDirs = [ stateDir ] ++ (map (e: (normalise e).src) rwBinds);

      bwrapArgs =
        [ "--unshare-all" ]
        ++ (lib.optional network "--share-net")
        ++ [ "--die-with-parent" "--clearenv" ]
        ++ (lib.optional newSession "--new-session")
        ++ [ "--hostname" name ]

        # Base filesystem: store read-only, synthetic /proc and /dev.
        ++ [ "--ro-bind" "/nix/store" "/nix/store" ]
        ++ [ "--proc" "/proc" ]
        ++ [ "--dev" "/dev" ]

        # --dev only mkdir()s /dev/shm inside the /dev tmpfs. Mount a real,
        # explicitly-sized tmpfs over it so the limit is known rather than
        # "whatever half of RAM happens to be".
        ++ [ "--size" shmBytes "--tmpfs" "/dev/shm" ]

        ++ [ "--tmpfs" "/tmp" ]
        ++ (lib.concatMap (p: [ "--tmpfs" p ]) tmpfsPaths)

        # Graphics/compute userspace lives behind these on NixOS. Symlinks,
        # so the bind resolves through to the store path.
        ++ [ "--ro-bind-try" "/run/opengl-driver" "/run/opengl-driver" ]
        ++ [ "--ro-bind-try" "/run/opengl-driver-32" "/run/opengl-driver-32" ]

        # Enough of /etc for name resolution and getpwuid(). Nothing secret.
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

    in
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.bubblewrap pkgs.coreutils ];
      text = ''
        # Host-side state directories must exist before bwrap binds them.
        mkdir -p ${lib.escapeShellArgs hostDirs}

        exec bwrap \
          ${lib.escapeShellArgs bwrapArgs} \
          -- ${lib.escapeShellArgs command} "$@"
      '';
    };

in
{
  inherit mkSandbox gib;
}

/* NOTES

   Why no "proxy" network mode here.
   ---------------------------------
   The topologically-enforced allowlist we discussed (unshare netns, then
   slirp4netns or a veth pair, with a CONNECT proxy as the only reachable
   endpoint) needs a helper attached to the sandbox's network namespace
   *after* bwrap has created it. That means --info-fd, reading the child pid,
   and a start-up race between "namespace exists" and "process runs". It is
   doable but it is not a five-line wrapper, and a half-implemented version
   silently degrades to no isolation. So this file gives you honest none/host,
   and the proxy mode is a separate piece of work.

   If you want it: `bwrap --unshare-net --info-fd 3 ... 3>pipe`, parse
   `.["child-pid"]` out of the JSON, then
   `slirp4netns --configure --mtu=65520 --disable-host-loopback $PID tap0`
   and point HTTP(S)_PROXY at slirp's gateway. nftables on a veth pair is the
   stronger variant because it also catches raw sockets and DNS, which the
   proxy-env-var approach does not.

   Escape surfaces, ranked.
   ------------------------
   1. devBinds. /dev/kvm and /dev/kfd are direct kernel interfaces; a bug
      there bypasses the namespace entirely. Everything else here is
      namespace-mediated.
   2. The kernel itself. This is a namespace jail sharing your kernel. For
      firmware you did not build, QEMU without --dev-bind /dev/kvm (TCG only)
      or a real VM remains the correct boundary.
   3. /dev/shm is not an escape surface -- it is tmpfs, not a device node,
      and each sandbox gets its own instance. The realistic failure is
      filling it and OOMing, which is why it is sized.

   No resource limits here.
   ------------------------
   bubblewrap does no accounting. If you want memory/CPU caps, wrap the
   generated script:  systemd-run --user --scope -p MemoryMax=32G -- <script>
*/
