{ persist, lib, ... }:
persist.user.mkModule {
  name = "taskwarrior";
  options = { enable = lib.mkEnableOption "Taskwarrior persist"; };
  config = { value, ... }:
    lib.mkIf value.enable { directories = [ ".local/share/task" ]; };
}
