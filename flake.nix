{
  description = "My Home Manager configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # Use the appropriate branch
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # Define a specific configuration for your user and system
    homeConfigurations."setkeh@nixos-e7250" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      /* modules = [ ./home.nix ]; # Imports your existing home.nix file */
      # Add other necessary arguments like username, homeDirectory, etc.
      home.username = "setkeh";
      home.homeDirectory = "/home/setkeh";
      home.stateVersion = "25.11"; # Match your state version
    };
  };
}
