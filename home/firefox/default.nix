let
  search = {
    bing_global = { pkgs, ... }: {
      name = "Bing Global";
      value = {
        description = "Bing Global";
        urls = [{
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
        }];
        icon = "https://global.bing.com/sa/simg/favicon-trans-bg-blue-mg.ico";
        definedAliases = [ "@gbing" ];
      };
    };
  };

  profile = {
    base = {
      "browser.download.useDownloadDir" = false;
      "browser.download.start_downloads_in_tmp_dir" = true;

      "network.cookie.lifetimePolicy" = 2; # delete cookies when closed
      "browser.privatebrowsing.autostart" = true;

      "signon.rememberSignons" = false;

      "browser.tabs.warnOnClose" = true;
    };
  };
in {
  inherit search profile;

  default = { pkgs, ... }@args: {
    programs.firefox = {
      enable = true;
      profiles = {
        default = {
          settings = profile.base;
          search = let gbing = search.bing_global args;
          in {
            engines = { ${gbing.name} = gbing.value; };
            force = true;
            default = gbing.name;
          };
          isDefault = true;
        };
        test = { id = 1; };
      };
    };
  };
}
