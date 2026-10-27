{
  devLib,
  local-lib,
  ...
}:
let
  name = "javascript";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "JavaScript";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { ... }: {
        cfglib.develop.prettier = {
          enable = true;
          languages = {
            javascript = true;
            javascriptreact = true;
          };
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      cfglib.develop.prettier = {
        enable = true;
        languages = {
          javascript = true;
          javascriptreact = true;
        };
      };
    }
  );

  home =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.javascript = {
          enable = mkEnableOption "JavaScript environment";

          yarn.enable = local-lib.options.mkDisableOption "Yarn package manager";
          pnpm.enable = local-lib.options.mkDisableOption "Pnpm package manager";
        };
      };

      config =
        let
          cfg = config.cfglib.develop.javascript;
        in
        lib.mkIf cfg.enable {
          home.packages = [
            pkgs.nodejs
            (lib.mkIf cfg.yarn.enable pkgs.yarn)
            (lib.mkIf cfg.pnpm.enable pkgs.pnpm)
          ];
        };
    };
}
