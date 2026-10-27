{
  persist,
  options,
  vscodium,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "typst";
    options = {
      enable = lib.mkEnableOption "Typst";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cache/typst/packages" ]; };
  };
}
