{ inputs, pkgs, ... }:
{
  nix = {
    settings = {
      sandbox = true;
      # put build dir in protected path for security
      # see https://lix.systems/blog/2025-06-24-lix-cves/
      build-dir = "/nix/var/nix/builds";
      auto-optimise-store = true;
      experimental-features = "nix-command flakes ca-derivations";
    };

    registry = builtins.mapAttrs (name: value: { flake = value; }) (
      builtins.removeAttrs inputs [ "self" ]
    );

    # TODO: use stable version when develop shell was fixed (nix pr #13916,
    # nix 2.32.0 or later
    package = pkgs.nixVersions.latest;
  };
}
