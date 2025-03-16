# User for testing configuration
{
  system.default =
    { ... }:
    {
      users.users.test = {
        uid = 1100;
        isNormalUser = true;
      };
    };
}
