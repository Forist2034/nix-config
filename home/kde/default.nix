let
  bluedevil =
    { lib, ... }:
    {
      xdg.configFile."bluedevilglobalrc".text = lib.generators.toINI { } {
        Global.launchState = "disable";
      };
    };
  baloo =
    { lib, ... }:
    {
      xdg.configFile."baloofilerc".text = lib.generators.toINI { } {
        "Basic Settings".Indexing-Enabled = false;
      };
    };
  mute =
    { lib, ... }:
    {
      xdg.configFile."plasmaparc".text = lib.generators.toINI { } { General.GlobalMute = true; };
    };
  dolphin =
    { lib, ... }:
    {
      xdg.configFile."dolphinrc".text = lib.generators.toINI { } { DetailsMode.PreviewSize = 16; };
    };
  konsole = import ./konsole;
in
{
  inherit
    bluedevil
    baloo
    mute
    dolphin
    konsole
    ;

  default =
    { ... }:
    {
      imports = [
        baloo
        mute
        dolphin
        konsole.default
      ];

      # use system font config
      xdg.configFile."kdeglobals".text = ''
        [General]
        fixed=Monospace,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
        font=Sans Serif,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
        menuFont=Sans Serif,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
        smallestReadableFont=Sans Serif,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
        toolBarFont=Sans Serif,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

        [WM]
        activeFont=Sans Serif,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
      '';
    };
}
