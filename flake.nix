{
  description = "My Home Manager configuration flake";

  inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-channel.url = "github:setkeh/nixpkgs-channel";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, sops-nix, ... }@inputs: {
    nixosConfigurations = {
      # E7250 Laptop Config
      nixos-e7250 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos-e7250

          /* Overlay Module */
          ({ config, pkgs, ... }: {
            pkgs = import inputs.nixpkgs {
              overlays = [
                /* My Custom Package Channel */
                (import ./etc/overlays/nixpkgs-channel.nix { inherit inputs; })

                /* Custom Package Configuration */
                (import ./etc/overlays/slstatus.nix)
                (import ./etc/overlays/dwm.nix)
                (import ./etc/overlays/age.nix)
              ];
              config = {
                allowUnfree = true;
                allowUnfreePredicate = (_: true);
              };
            };
          })

          sops-nix.nixosModules.sops

          ({ config, ...}: {
            sops = {
              age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              defaultSopsFile = ./secrets/nixos-e7250.yaml;
              secrets = {
                /* Im not sure if there is a better way to do this but it works for now */
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
