{ inputs, ... }: {
  nix = {
    settings = {
      sandbox = true;
      auto-optimise-store = true;
      experimental-features = "nix-command flakes ca-derivations";
    };

    registry = builtins.mapAttrs (name: value: { flake = value; })
      (builtins.removeAttrs inputs [ "self" ]);
  };
}
