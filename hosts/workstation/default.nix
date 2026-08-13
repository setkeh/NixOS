{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/gpg.nix
    ../../common/cleanup.nix
    ../../common/firewall.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.configurationLimit = 10;

  networking.hostName = "workstation-nixos"; # Define your hostname.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Tailscale Client Options
  services.tailscale.useRoutingFeatures = "client";

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  programs.niri.enable = true;
  # programs.niri.package = pkgs.niri-stable;  # or niri-unstable

  # Login manager: greetd + tuigreet launching a niri session
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
      user = "greeter";
    };
  };

  # XDG portals: screenshots, file pickers, screen share
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
   };

  # Electron/Chromium apps run native Wayland (helps VS Code, Claude-in-Chrome, etc.)
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;                 # 32-bit for Steam/Wine/Proton
    extraPackages = with pkgs; [
      rocmPackages.clr.icd              # OpenCL via ROCm runtime (optional)
      # NOTE: RADV (bundled with Mesa) is the default Vulkan driver — do NOT add amdvlk.
    ];
  };

  users.users.setkeh = {
    isNormalUser = true;
    description = "setkeh";
    extraGroups = [ "networkmanager" "wheel" "video" "render" ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  /* These packages to make yubikey work */
  environment.systemPackages = with pkgs; [
    yubikey-manager
    libfido2
    ccid
    age-plugin-yubikey
    age
    nfs-utils
  ];

  environment.shellInit = ''
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  services.openssh = {
    enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Keyring
  services.gnome.gnome-keyring.enable = true;

  # RECOMMENDED: run ROCm PyTorch in a container, not a Nix build.
  virtualisation.podman.enable = true;
  #   podman run --device=/dev/kfd --device=/dev/dri \
  #     --group-add keep-groups --security-opt seccomp=unconfined \
  #     -it rocm/pytorch:latest

  # Non-7900 RDNA3 (7800/7700 = gfx1101/1102) may need this; 7900s do NOT:
  # environment.variables.HSA_OVERRIDE_GFX_VERSION = "11.0.0";

  # ---------- optional: NATIVE ROCm instead of containers ----------
  # environment.systemPackages = with pkgs; [ rocmPackages.rocminfo rocmPackages.rocm-smi ];
  # systemd.tmpfiles.rules = [ "L+ /opt/rocm - - - - ${pkgs.rocmPackages.clr}" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
