{
  system =
    let
      profiles = {
        base =
          { ... }:
          {
            users.users.reid = {
              uid = 1002;
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              openssh.authorizedKeys.keyFiles = [
                ./reid/nixos-desktop0_ed25519.pub
                ./reid/nixos-laptop0_ed25519.pub
              ];
            };
          };
      };
    in
    {
      inherit profiles;

      default =
        { ... }:
        {
          imports = [ profiles.base ];

          persistence.root.users.reid = {
            gpg.enable = true;
            gopass.enable = true;

            thunderbird = {
              enable = true;
              profiles.default.enable = true;
            };

            gh.enable = true;
            kwallet.enable = true; # gh stores token in kwallet
          };
        };
    };

  home =
    let
      profiles = {
        git =
          { ... }:
          {
            programs.git = {
              enable = true;
              userName = "Jose Lane";
              userEmail = "dariankline@outlook.com";
              signing = {
                key = "714C3CCC60466A93";
                signByDefault = true;
              };
            };
          };

        email =
          { ... }:
          {
            accounts.email.accounts = {
              outlook = {
                primary = true;
                address = "dariankline@outlook.com";
                realName = "Jose Lane";
                userName = "dariankline@outlook.com";
                flavor = "outlook.office365.com";

                thunderbird.settings = id: {
                  "mail.server.server_${id}.authMethod" = 10; # oauth2
                };
              };
            };
          };
      };
    in
    {
      inherit profiles;

      default =
        { parts, ... }:
        {
          imports = [
            profiles.git
            profiles.email

            parts.gpg.home.default
            parts.gopass.home.default
            parts.github.home.default
            parts.thunderbird.home.default
          ];

          accounts.email.accounts = {
            outlook = {
              thunderbird.enable = true;
            };
          };
        };
    };
}
