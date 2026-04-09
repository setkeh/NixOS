final: prev: {
  age = let
    wrapped = prev.age.withPlugins (ps: [ ps.age-plugin-yubikey ]);
  in
    wrapped.overrideAttrs (old: {
      meta =
        (old.meta or {})
          // {
            mainProgram = "age";
          };
      });
  }