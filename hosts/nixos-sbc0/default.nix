{ local-lib, ... }:
{
  system = "armv7l-linux";

  userPasswordFile = user: "/mnt/config/var/lib/passwords/${user}";

  hardware = {
    cpu = {
      threads = 4;
    };
  };
}
