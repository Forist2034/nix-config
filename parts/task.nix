{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "task";
          options = with lib; {
            default = {
              enable = mkEnableOption "Task and time management";
            };
          };
          config =
            { value, ... }:
            lib.mkIf value.default.enable {
              directories = [
                ".local/share/timewarrior"
                ".local/share/io.github.alainm23.planify"
                ".config/superProductivity"
                ".taskbook"
              ];
            };
        };
      };
    in
    {

      default = modules.persist;
    };

  home = {
    default =
      {
        pkgs,
        inputs,
        info,
        ...
      }:
      {
        home.packages = with pkgs; [
          todoman
          radicale
          pimsync

          timewarrior
          planify
          sleek-todo
          super-productivity
          ttdl
          taskbook

          inputs.task-util.packages.${info.system}.default
        ];
      };
  };
}
