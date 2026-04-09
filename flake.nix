{
  description = "My Home Manager configuration flake";

  inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      # WSL Configurationc
      nixos-e7250 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos-e7250

          /* Overlay Module */
          ./etc/overlays

          sops-nix.nixosModules.sops

          ({ config, ...}: {
            sops = {
              age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              defaultSopsFile = ./secrets/nixos-e7250.yaml;
              secrets = {
                /* Im not sure if there is a better way to do this */
                "nixos-e7250/fish_aliases" = {
                  owner = config.users.users.setkeh.name;
                  path = "/home/setkeh/.config/fish/conf.d/alias.fish";
                };
              };
            };
          })
        
          home-manager.nixosModules.home-manager
          ({ config, lib, pkgs, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.sharedModules = [
              inputs.sops-nix.homeManagerModules.sops
            ];
            home-manager.users.setkeh = { config, pkgs, ... }: {
              imports = [
                ./home/nixos-e7250
              ];
            };
          })
        ];
      };
    };
  };
}
