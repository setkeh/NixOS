# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    #./services.nix
    #../../common/gpg.nix
    ../../common/cleanup.nix
    ../../common/firewall.nix
    ./hermes/hermes.nix
    ./docker/honcho/honcho.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "ai-server"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm = {
    enable = true;
    #background = "/etc/wallpaper/IMG-57dc78dcb5f8086349cdb611a4a0fe5f-V.jpg";
    extraConfig = ''
      background-style = centered
    '';
  };

  services.xserver.displayManager.sessionCommands = ''
    # Commands to run on login
    #${pkgs.feh}/bin/feh --bg-fill /home/setkeh/Wallpaper/uwp5001833.png &
  '';

  #services.xserver.desktopManager.xfce.enable = true;
  services.xserver.windowManager.dwm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  users.users.setkeh = {
    isNormalUser = true;
    description = "setkeh";
    extraGroups = [ "networkmanager" "wheel" "hermes" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMmH6ShUmcPTP9SpyOIKpoZoR8YlFld1J5QUKPnkUW6y setkeh@github/121839022"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXsYSlu1gncZLQ1TWdx4T4dZp0ltb7G61sfeCLSWXn8 setkeh@github/70758014"
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  /* System Packages */
  environment.systemPackages = with pkgs; [
    age
    nfs-utils
    sops
  ];

  environment.shellInit = ''
    #export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  services.openssh = {
    enable = true;
    settings = {
      # require public key authentication for better security
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";

      # SSH and GPG Agent Forwarding
      AllowAgentForwarding = true;
      # Unlink old socket files when a new connection is established. 
      # This fixes errors where forwarding breaks on reconnecting.
      StreamLocalBindUnlink = true;
    };
  };

  programs.gnupg.agent = {
    enable = true;
    # Ensure pinentry-tty or similar is available if the server needs to ask for anything
    enableSSHSupport = false; #Needs to be disabled as we are sending this through from workstation/laptop envs
    pinentryPackage = pkgs.pinentry-gtk2; 
  };

  # Prevent systemd-managed gpg-agent sockets from conflicting with the socket you are forwarding over SSH.
  systemd.user.services.gpg-agent.environment.gpg_agent_env_file = "/dev/null";

  systemd.user.tmpfiles.rules = [
    "d %t/gnupg 0700 - - - -"
  ];

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Keyring
  services.gnome.gnome-keyring.enable = false;

  # Need Flatpak for Synergy
  services.flatpak.enable = true;

  # Ensure standard desktop integration files are watched
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
