{ ... }:
{
  programs.thunderbird = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
      };
    };
    settings = {
      # only allow cookies from visited site, for oauth2 login
      "network.cookie.cookieBehavior" = 3;
      "places.history.enabled" = false; # disable history
    };
  };
}
