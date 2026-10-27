{
  options,
  persist,
  lib,
  vscodium,
  ...
}:
{
  system = persist.user.mkModule {
    name = "javascript";
    options = {
      enable = lib.mkEnableOption "Javascript";
      yarn.enable = options.mkDisableOption "Yarn";
      pnpm.enable = options.mkDisableOption "Pnpm";
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
          (lib.mkIf value.pnpm.enable [
            ".cache/pnpm"
            ".local/share/pnpm/store"
          ])
        ];
      };
  };
}
