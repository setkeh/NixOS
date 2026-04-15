{ inputs }: final: prev: {
  inherit (inputs.nixpkgs-channel.packages."x86_64-linux")
    mqtt-explorer;
}