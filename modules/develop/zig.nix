{
  persist,
  firefox,
  options,
  lib,
  vscodium,
  ...
}:
{
  system = persist.user.mkModule {
    name = "zig";
    options = {
      enable = lib.mkEnableOption "Zig";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".cache/zig/p" ]; };
  };
}
