let
  bluedevil = { lib, ... }: {
    xdg.configFile."bluedevilglobalrc".text =
      lib.generators.toINI { } { Global.launchState = "disable"; };
  };
  baloo = { lib, ... }: {
    xdg.configFile."baloofilerc".text =
      lib.generators.toINI { } { "Basic Settings".Indexing-Enabled = false; };
  };
  mute = { lib, ... }: {
    xdg.configFile."plasmaparc".text =
      lib.generators.toINI { } { General.GlobalMute = true; };
  };
  dolphin = { lib, ... }: {
    xdg.configFile."dolphinrc".text =
      lib.generators.toINI { } { DetailsMode.PreviewSize = 16; };
  };
  konsole = import ./konsole;
in {
  inherit bluedevil baloo mute dolphin konsole;

  default = { ... }: { imports = [ baloo mute dolphin konsole.default ]; };
}
