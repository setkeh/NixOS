{ config, pkgs, lib, ... }: {
    programs.obsidian = {
        enable = true;

        vaults.notes.target = "SecondMind";

        defaultSettings.app = {
            alwaysUpdateLinks = true;
            spellcheck = true;
        };
    };
}