{ ... }: {
  programs.thunderbird = {
    enable = true;
    profiles = { default = { isDefault = true; }; };
    settings = {
      "network.cookie.cookieBehavior" = 2; # disable cookies
      "places.history.enabled" = false; # disable history
    };
  };
}
