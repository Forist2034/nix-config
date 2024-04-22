{
  base = { ... }: {
    users.users.reid = {
      uid = 1002;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  git = { ... }: {
    programs.git = {
      enable = true;
      userName = "Jose Lane";
      userEmail = "dariankline@outlook.com";
    };
  };

  email = { ... }: {
    accounts.email.accounts = {
      outlook = {
        primary = true;
        address = "dariankline@outlook.com";
        realName = "Jose Lane";
        userName = "dariankline@outlook.com";
        flavor = "outlook.office365.com";
      };
    };
  };
}
