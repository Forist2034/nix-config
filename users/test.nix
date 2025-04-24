# User for testing configuration
{
  system.default =
    { ... }:
    {
      users = {
        groups.test = {
          gid = 1100;
        };
        users.test = {
          uid = 1100;
          isNormalUser = true;
          group = "test";
        };
      };
    };
}
