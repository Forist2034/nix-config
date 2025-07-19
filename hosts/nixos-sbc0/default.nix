{ local-lib, ... }:
{
  system = "armv7l-linux";

  userPasswordFile = user: "/mnt/config/etc/user-passwords/${user}";

  hardware = {
    cpu = {
      threads = 4;
    };
  };
}
