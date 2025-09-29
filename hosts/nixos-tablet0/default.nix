{ local-lib, ... }:
{
  system = "x86_64-linux";

  userPasswordFile = user: "/nix/secrets/passwords/${user}";

  hardware = {
    cpu = {
      threads = 16;
    };
  };

  home = {
    develop.configuration = import ./home.nix;
  };
}
