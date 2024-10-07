{
  options,
  persist,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "javascript";
    options = {
      enable = lib.mkEnableOption "Javascript";
      yarn.enable = options.mkDisableOption "Yarn";
    };
    config =
      { value, ... }:
      lib.mkIf value.enable {
        directories = lib.mkMerge [
          [ ".npm" ]
          (lib.mkIf value.yarn.enable [
            ".yarn"
            ".cache/yarn"
          ])
        ];
      };
  };

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.javascript = {
          enable = mkEnableOption "JavaScript environment";

          env = {
            enable = options.mkDisableOption "JavaScript build tools";

            yarn.enable = options.mkDisableOption "Yarn package manager";
          };
        };
      };

      config =
        let
          cfg = config.develop.javascript;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.nodejs
            (lib.mkIf cfg.env.yarn.enable pkgs.yarn)
          ];
        };
    };
}
