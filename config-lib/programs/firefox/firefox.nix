{
  global =
    let
      profiles = {
        base = {
          policies = {
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
        };

        search.bing_global = {
          policies = {
            SearchEngines.Add = [
              {
                Name = "Global Bing";
                URLTemplate = "https://global.bing.com/search?q={searchTerms}&pq={searchTerms}&mkt=en-US";
                Method = "GET";
                IconURL = "https://global.bing.com/sa/simg/favicon-trans-bg-blue-mg.ico";
                Alias = "@gbing";
              }
            ];
          };
        };

        containers = { pkgs, ... }: {
          policies = {
            ExtensionSettings = {
              "@testpilot-containers" =
                let
                  extension = pkgs.fetchurl {
                    # UPDATE
                    url = "https://addons.mozilla.org/firefox/downloads/file/4733069/multi_account_containers-8.3.7.xpi";
                    hash = "sha256-f29e97EG0z0bmdLF5TogZdB/eEsYUv6bn3g5TptAUWU=";
                  };
                in
                {
                  installation_mode = "normal_installed";
                  install_url = "file://${extension}";
                  updates_disabled = true;
                };
            };
          };
        };
      };
    in
    {
      inherit profiles;

      default = {
        imports = [
          profiles.base
          profiles.search.bing_global
          profiles.containers
        ];
        policies = {
          SearchEngines.Default = "Global Bing";
        };
      };
    };
}
