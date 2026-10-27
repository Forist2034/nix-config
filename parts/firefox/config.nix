let
  settings = {
    base = { };
    backup = {
      "browser.backup.enabled" = true;
      "browser.backup.scheduled.enabled" = true;
      "browser.backup.scheduled.minimum-time-between-backups-seconds" = 4 * 60 * 60; # 4 hr
    };
  };

  profiles =
    let
      base = { };
    in
    {
      inherit base;
      default = base // {
        settings = settings.base // settings.backup;
      };
    };
in
{
  inherit
    settings
    profiles
    ;
}
