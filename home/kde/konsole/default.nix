let
  theme = {
    darkOneNuanced =
      { ... }:
      {
        xdg.dataFile."konsole/DarkOneNuanced.colorscheme".source = ./DarkOneNuanced.colorscheme;
      };
  };
  profile = {
    defaultDark =
      { lib, ... }:
      {
        xdg.dataFile."konsole/DefaultDark.profile".text = lib.generators.toINI { } {
          Appearance = {
            ColorScheme = "DarkOneNuanced";
            Font = "Cascadia Code NF,10,-1,5,50,0,0,0,0,0";
          };
          "Cursor Options".CursorShape = 1; # I-beam
          General = {
            Name = "Default Dark";
            Parent = "FALLBACK/";
          };
          Scrolling.HistorySize = 5000;
        };
      };
  };
in
{
  inherit theme profile;

  default =
    { lib, ... }:
    {
      imports = [
        theme.darkOneNuanced
        profile.defaultDark
      ];

      xdg.configFile."konsolerc".text = lib.generators.toINI { } ({
        "Desktop Entry".DefaultProfile = "DefaultDark.profile";
        TabBar.NewTabBehavior = "PutNewTabAfterCurrentTab";
      });
    };
}
