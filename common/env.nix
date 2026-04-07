{ config, pkgs, ... }:

{
  home.file.".config/fish/conf.d/email.fish" = {
    text = ''
      set -x EMAIL (cat ${config.age.secrets.git-email.path})
    '';
  };
}
