/* hosts/workstation/sandbox.nix

   The *only* system-side dependencies of the bubblewrap sandboxes.
   Everything else lives in home/workstation/sandbox.nix.

   Import from hosts/workstation/default.nix:
     imports = [ ./sandbox.nix ];

   Keep this file small and keep it documented -- the whole point of the
   split is that future-you can see at a glance what the home-manager side
   is relying on.
*/
{ config, pkgs, lib, ... }:

{
  ##########################################################################
  # 1. Unprivileged user namespaces.
  #
  # This is already true by default on NixOS with the stock kernel; the
  # option only actually does anything on a hardened kernel, where it flips
  # kernel.unprivileged_userns_clone. Stated explicitly so that switching to
  # linuxPackages_hardened later fails loudly rather than silently breaking
  # every sandbox.
  ##########################################################################
  security.allowUserNamespaces = true;

  ##########################################################################
  # 2. Group membership.
  #
  # home-manager cannot do this -- it manages files and packages inside an
  # existing account, not the account's group list.
  #
  #   render -> /dev/kfd and /dev/dri/renderD*  (ROCm compute)
  #   video  -> /dev/dri/card*
  #   kvm    -> /dev/kvm                        (only if you want QEMU
  #                                              acceleration; drop it if
  #                                              you stay on TCG)
  ##########################################################################
  users.users.setkeh.extraGroups = [ "render" "video" "kvm" ];

  ##########################################################################
  # 3. bwrap on the system PATH.
  #
  # Not strictly required -- the generated wrappers reference it by store
  # path via runtimeInputs -- but you will want it interactively for
  # debugging bind-mount ordering.
  ##########################################################################
  environment.systemPackages = [ pkgs.bubblewrap ];

  ##########################################################################
  # 4. Graphics stack.
  #
  # mkDefault so this does not fight whatever hosts/workstation/default.nix
  # already sets. enable32Bit is for Proton/DXVK, not for ROCm.
  ##########################################################################
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault true;
  };

  # NOTE: deliberately NOT enabling services.ollama. The whole point is that
  # ollama runs inside the sandbox, launched by hand, with no systemd unit
  # and nothing in the system profile.
}
