let
  settings = {
    base = { };
    backup = {
      "browser.backup.enabled" = true;
      "browser.backup.scheduled.enabled" = true;
      "browser.backup.scheduled.minimum-time-between-backups-seconds" = 4 * 60 * 60; # 4 hr
    };
  };

  policies = {
    base = {
      PromptForDownloadLocation = true;
      DisableFormHistory = true;
      OfferToSaveLogins = false;
      HttpsOnlyMode = "enabled";
      Preferences =
        let
          user = v: {
            Value = v;
            Status = "user";
          };
        in
        {
          "browser.tabs.warnOnClose" = user true;
          "browser.bookmarks.max_backups" = user (-1); # unlimited number of backups
          # allow override in user settings
          "browser.download.start_downloads_in_tmp_dir" = user true;

          "extensions.activeThemeID" = user "default-theme@mozilla.org";
        };
    };

    search = {
      bing_global = {
        Name = "Global Bing";
        URLTemplate = "https://global.bing.com/search?q={searchTerms}&pq={searchTerms}&mkt=en-US";
        Method = "GET";
        IconURL = "https://global.bing.com/sa/simg/favicon-trans-bg-blue-mg.ico";
        Alias = "@gbing";
      };
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
    policies
    profiles
    ;
}
