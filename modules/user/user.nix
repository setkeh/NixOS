{pkgs, lib, config, ...}:
with builtins;
with lib;
let
  cfg = config.sys.users;
in {
  primaryUser = {
    name = mkOption {
      type = types.str;
      default = "setkeh";
      description = "The username of the primary user on the system";
    };
  };

  extraGroups = mkOption {
    type = types.listOf types.str;
    default = [];
    description = "Extra groups to add to primary user";
  };

  shell = mkOption {
    type = types.package;
    default = pkgs.fish;
    description = "Sets the shell used by primary user";
  };

  config = {
    users.users."${cfg.primaryUser.name}" = {
      name = cfg.primaryUser.name;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = cfg.primaryUser.extraGroups;
      uid = 1000;
      initialPassword = "P@ssw0rd01";
    };

    users.users.root = {
      name = "root";
      initialPassword = "P@ssw0rd01";
    };
  };
}
