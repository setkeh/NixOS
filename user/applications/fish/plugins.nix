{ config, pkgs, ... }:

{
  programs.fish.plugins = [{
    name = "hydro";
    src = pkgs.fetchFromGitHub {
    owner = "setkeh";
    repo = "hydro";
    rev = "7068cf4b8e77d638be3e9b5872e916502fbc6bc8";
    sha256 = "0nwz632cyvc0pvfv9i1ba75cs9yjy2wmfyhxnp53pipc84h9yca8";
  };
 }];
}
