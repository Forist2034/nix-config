# User for testing configuration
{
  base = { ... }: {
    users.users.test = {
      uid = 1100;
      isNormalUser = true;
    };
  };
}
