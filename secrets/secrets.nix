let
  setkeh = "age1yubikey1qt07k5ds79pjjetqc7977eg2xr345mv832s9u9dv3aq2976e806l7heqxgg";

  users = [ setkeh ];

in
{
  "gpg-email.age".publicKeys = [ setkeh ];
  "armored-secret.age" = {
    publicKeys = [ setkeh ];
    armor = true;
  };
}
