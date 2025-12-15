{ ... }:
{
  home = {
    default =
      { pkgs, ... }:
      {
        i18n.inputMethod = {
          enable = true;
          type = "fcitx5";
          fcitx5 = {
            waylandFrontend = true;
            addons = [ pkgs.fcitx5-rime ];
            settings = {
              inputMethod = {
                GroupOrder."0" = "Default";
                "Groups/0" = {
                  Name = "Default";
                  "Default Layout" = "us";
                  DefaultIM = "rime";
                };
                "Groups/0/Items/0".Name = "keyboard-us";
                "Groups/0/Items/1".Name = "rime";
              };
            };
          };
        };
        home.packages = [
          pkgs.rime-data
          pkgs.rime-zhwiki
        ];
      };
  };
}
