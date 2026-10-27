{
  persist,
  options,
  vscodium,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "coursier";
    options = {
      enable = lib.mkEnableOption "Coursier";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cache/coursier" ]; };
  };
}
