{ inputs }: final: prev: {
  mqtt-explorer = final.callPackage
    (inputs.nixpkgs-channel + "/pkgs/by-name/mqtt-explorer/mqtt-explorer.nix")
    { };
}
