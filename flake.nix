{
  description = "My Home Manager configuration flake";

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # Use the appropriate branch
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, agenix, ... }@inputs: {
    nixosConfigurations = {
      # WSL Configuration
      wsl = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/wsl
          nixos-wsl.nixosModules.default
          {
            age = {
              identityPaths = [ "/home/setkeh/age-yubikey-identity-d56ab03e.txt" ];
              secrets = {
                gpg-email.file = ./secrets/gpg-email.age;
              };
            };
          }
          {
            environment.systemPackages = [ agenix.packages.x86_64-linux.default ];
          }
          home-manager.nixosModules.home-manager 
          agenix.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.setkeh = import ./home/wsl;
          }
        ];
      };

      # Laptop configuration
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/laptop
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.setkeh = import ./home/laptop;
          }
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
