{ config, pkgs, lib, ... }: {
    programs._1password.enable = true;          # wrapper + onepassword-cli group
    programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "setkeh" ];        # creates the onepassword group
    };
}