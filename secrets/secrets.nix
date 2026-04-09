let
  setkeh = "age1yubikey1qwauuw4tax2sr23ac6r77v5eff0n5209rrfmqqeadeak27ac2zthc3670ck";
  users = [ setkeh ];

  wsl = "age1yubikey1qt07k5ds79pjjetqc7977eg2xr345mv832s9u9dv3aq2976e806l7heqxgg";
  nixos-e7250 = "age1yubikey1qwauuw4tax2sr23ac6r77v5eff0n5209rrfmqqeadeak27ac2zthc3670ck";
  systems = [ wsl nixos-e7250 ];

in
{
  "fish-alias.age".publicKeys = users ++ systems;
  "test-alias.age".publicKeys = users ++ systems;
  "armored-secret.age" = {
    publicKeys = users ++ systems;
    armor = true;
  };
}
