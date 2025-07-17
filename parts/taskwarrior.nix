{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "taskwarrior";
          options = {
            enable = lib.mkEnableOption "Taskwarrior persist";
          };
          config = { value, ... }: lib.mkIf value.enable { directories = [ ".local/share/task" ]; };
        };
      };
    in
    {
      inherit modules;
      default = modules.persist;
    };

  home =
    let
      profiles = {
        default =
          { pkgs, ... }:
          {
            programs.taskwarrior = {
              enable = true;
              package = pkgs.taskwarrior3;
            };
          };
      };
    in
    {
      inherit profiles;

      default = profiles.default;
    };
}
