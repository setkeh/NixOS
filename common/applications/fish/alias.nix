({ osConfig, ...}: {
  # This file sources the decrypted aliases from the sops-nix service.
  # The secret itself is defined at the system level in flake.nix,
  # because it requires root permissions to decrypt.
  programs.fish.extraConfig = {
    nswitch = builtins.readFile osConfig.sops.secrets."fish_aliases/nswitch".content;
  };
})