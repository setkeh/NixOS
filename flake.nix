{
  description = "My Home Manager configuration flake";

  inputs = {
    #agenix = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # Use the appropriate branch
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    /* overlays.default = final: prev: {
        dwm = prev.callPackage ./etc/overlays/dwm.nix { };
        slstatus = prev.callPackage ./etc/overlays/alstatus.nix { };
      };

      packages.x86_64-linux = {
        inherit (pkgs) dwm;
        inherit (pkgs) slstatus; 
      }; */
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, sops-nix /*agenix*/, ... }@inputs: {
    nixosConfigurations = {
      # WSL Configurationc
      nixos-e7250 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nixos-e7250

          /* Overlay Module */
          ./etc/overlays

          /*agenix.nixosModules.default
          ({ pkgs, ... }: {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default pkgs.age-plugin-yubikey pkgs.age ];
          })*/

          sops-nix.nixosModules.sops

          {
            sops = {
              age.keyFile = ../../.identitys/age-yubikey-identity-44672097.txt; # Relative to flake.nix
              defaultSopsFile = ./secrets/fish_alias.yaml;
            };
          }

          /*({ lib, pkgs, ...}: {
            age = {
              ageBin = "PATH=$PATH:${lib.makeBinPath [ pkgs.age-plugin-yubikey ]} ${pkgs.age}/bin/age";
              identityPaths = [ "/home/setkeh/.identitys/age-yubikey-identity-44672097.txt" ];
              secrets = {
                test-alias.file = ./secrets/fish-alias.age;
                fish-alias.file = ./secrets/fish-alias.age;
              };
            };
          })*/
        
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
                #agenix.homeManagerModules.default
              ];

              sops = {
                age.keyFile = "${config.home.homeDirectory}/.identitys/age-yubikey-identity-44672097.txt"; # Relative to flake.nix
                defaultSopsFile = ./secrets/fish_alias.yaml;
                secrets = {
                  "fish_aliases" = {
                    path = "${config.home.homeDirectory}/.config/fish/sops_aliases.fish";
                  };
                };
              };

              /*sops.secrets."fish-aliases" = {
                path = "${config.home.homeDirectory}/.config/fish/sops_aliases.fish";
              };*/

              /*sops = {
                age.keyFile = /home/setkeh/.identitys/age-yubikey-identity-44672097.txt;
                defaultSopsFile = ./secrets/fish-alias.yaml;
              };*/
              /* age = {
                #ageBin = "PATH=$PATH:${lib.makeBinPath [ pkgs.age-plugin-yubikey ]} ${pkgs.age}/bin/age";
                identityPaths = [ "/home/setkeh/.identitys/age-yubikey-identity-44672097.txt" ];
                secrets = {
                  fish-alias.file = ./secrets/fish-alias.age;
                };
              };*/
            };
          })
        ];
      };
    # Define a specific configuration for your user and system
    #homeConfigurations."setkeh@nixos-e7250" = home-manager.lib.homeManagerConfiguration {
    #  inherit pkgs;
    #  /* modules = [ ./home.nix ]; # Imports your existing home.nix file */
    #  # Add other necessary arguments like username, homeDirectory, etc.
    #  home.username = "setkeh";
    #  home.homeDirectory = "/home/setkeh";
    #  home.stateVersion = "25.11"; # Match your state version
    #};
  };
 };
}
