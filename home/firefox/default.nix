let
  search = {
    bing_global = {
      name = "Bing Global";
      value = {
        description = "Bing Global";
        urls = [
          {
            template = "https://global.bing.com/search";
            params = [
              {
                name = "q";
                value = "{searchTerms}";
              }
              {
                name = "mkt";
                value = "en-US";
              }
            ];
          }
        ];
        icon = "https://global.bing.com/sa/simg/favicon-trans-bg-blue-mg.ico";
        definedAliases = [ "@gbing" ];
      };
    };
  };

  settings = {
    base = {
      "privacy.history.custom" = true;
      "privacy.sanitize.sanitizeOnShutdown" = true;
      "privacy.clearOnShutdown.cache" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = true;
      "privacy.clearOnShutdown.sessions" = true;
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
        };
    };
  };

  profiles =
    let
      base = {
        search = {
          engines = {
            ${search.bing_global.name} = search.bing_global.value;
          };
          force = true;
          default = search.bing_global.name;
        };
      };
    in
    {
      inherit base;
      default = base // {
        settings = settings.base;
      };
    };
in
{
  inherit
    search
    settings
    policies
    profiles
    ;

  default =
    { pkgs, ... }@args:
    {
      programs.firefox = {
        enable = true;
        policies = policies.base;
        profiles = {
          default = profiles.default // {
            isDefault = true;
          };
          test = profiles.base // {
            id = 1;
          };
        };
      };
    };
}
