/* home/workstation/sandbox.nix

   Add to home/workstation/default.nix imports:
     ./sandbox.nix

   Depends on hosts/workstation/sandbox.nix for:
     - security.allowUserNamespaces
     - users.users.setkeh.extraGroups = [ "render" "video" "kvm" ]

   Imported by relative path rather than through flake.lib, because
   home-manager.extraSpecialArgs is not set on the workstation config so
   `inputs` is not in scope here. If you would rather have it match
   mkClaudeInfra, see the flake.nix note at the bottom of this file.
*/
{ config, pkgs, lib, ... }:

let
  sandboxLib = import ../../common/sandbox { inherit pkgs lib; };
  inherit (sandboxLib) mkSandbox;

  home = config.home.homeDirectory;
  state = "${home}/.local/state/sandbox";

  ########################################################################
  # Ollama.
  #
  # Untrusted weights with filesystem access is the accident class this is
  # actually good at catching.
  #
  # network = true is a real concession: unsharing the netns would make the
  # server unreachable from the host, since 127.0.0.1 inside the sandbox is
  # not 127.0.0.1 outside it. Until the slirp4netns work is done, the
  # meaningful boundary here is the filesystem one -- the process can see
  # its model directory and nothing else in ~.
  ########################################################################
  ollama = mkSandbox {
    name = "ollama-sandbox";
    packages = [ pkgs.ollama-rocm ];
    command = [ "${pkgs.ollama-rocm}/bin/ollama" ];
    stateDir = "${state}/ollama";
    rwBinds = [ "${home}/.ollama" ];
    devBinds = [ "/dev/kfd" "/dev/dri" ];
    network = true;
    newSession = true;

    # ROCm and llama.cpp both lean on /dev/shm for buffer handoff between
    # the userspace driver and the compute process. 8 GiB is generous; drop
    # it if you would rather find the real floor empirically.
    shmSizeGiB = 8;

    env = {
      OLLAMA_MODELS = "${home}/.ollama/models";
      OLLAMA_HOST = "127.0.0.1:11434";

      # gfx1100 (7900 XTX) is natively supported by ROCm -- this override is
      # for gfx1101/1102 (7800/7700 XT) and is a no-op for you. Left here
      # only so you know why it is absent.
      # HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };
  };

  ########################################################################
  # Claude Code.
  #
  # The valuable boundary is filesystem, not network: this cannot reach
  # ~/.config/sops, ~/.gnupg, or the gpg-agent socket, because nothing binds
  # them. That is the whole point.
  #
  # Takes the repo path as $1:  claude-sandbox ~/src/infra-terraform
  ########################################################################
  claude = mkSandbox {
    name = "claude-sandbox";
    packages = [
      pkgs.claude-code
      pkgs.git
      pkgs.bashInteractive
      pkgs.ripgrep
      pkgs.fd
    ];
    command = [ "${pkgs.claude-code}/bin/claude" ];
    stateDir = "${state}/claude";

    # Deliberately NOT: ~/.config/sops, ~/.gnupg, ~/.ssh, $GPG_AGENT_INFO.
    # Add the repo you are working in per-invocation instead of blanket
    # binding ~/src.
    rwBinds = [ "${home}/src/scratch" ];
    roBinds = [ "${home}/.config/git" ];

    network = true;

    # Interactive TTY: setsid() would detach the controlling terminal and
    # break job control. Trade-off is TIOCSTI is not blocked -- acceptable
    # here because you are the one at the keyboard.
    newSession = false;

    workDir = "${home}/src/scratch";
    shmSizeGiB = 1;
  };

  ########################################################################
  # QEMU for coreboot.
  #
  # TCG only -- no /dev/kvm hole. Firmware images are small and boot fast
  # enough under emulation that the acceleration is rarely worth the
  # kernel-interface exposure.
  #
  # Network unshared entirely: firmware under test has no business talking
  # to anything.
  ########################################################################
  coreboot = mkSandbox {
    name = "coreboot-sandbox";
    packages = [ pkgs.qemu pkgs.bashInteractive ];
    command = [ "${pkgs.bashInteractive}/bin/bash" ];
    stateDir = "${state}/coreboot";
    rwBinds = [ "${home}/src/coreboot" ];
    network = false;
    devBinds = [ ];
    workDir = "${home}/src/coreboot";
    shmSizeGiB = 2;
  };

  # Same, but with the KVM hole punched. Separate wrapper so that using
  # acceleration is an explicit, visible decision rather than a default.
  # Requires the "kvm" group from hosts/workstation/sandbox.nix.
  corebootKvm = mkSandbox {
    name = "coreboot-sandbox-kvm";
    packages = [ pkgs.qemu pkgs.bashInteractive ];
    command = [ "${pkgs.bashInteractive}/bin/bash" ];
    stateDir = "${state}/coreboot";
    rwBinds = [ "${home}/src/coreboot" ];
    network = false;
    devBinds = [ "/dev/kvm" ];
    workDir = "${home}/src/coreboot";
    shmSizeGiB = 2;
  };

in
{
  home.packages = [
    ollama
    claude
    coreboot
    corebootKvm
  ];
}

/* Optional: routing this through flake.lib instead.

   1. In flake.nix, alongside mkClaudeInfra:

        lib = {
          mkClaudeInfra = import ./common/claude-infra;
          mkSandbox     = import ./common/sandbox;
        };

   2. In the workstation home-manager block, pass inputs down:

        home-manager.extraSpecialArgs = { inherit inputs; };

   3. Then here:

        { config, pkgs, lib, inputs, ... }:
        let
          inherit (inputs.self.lib.mkSandbox { inherit pkgs lib; }) mkSandbox;
        in ...

   Worth doing if the WSL or laptop configs end up wanting sandboxes too.
   Not worth it for one host.
*/
