{
  persist,
  firefox,
  options,
  vscodium,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "rust";
    options = {
      enable = lib.mkEnableOption "Rust";
      cargo.enable = lib.mkEnableOption "Cargo persist";
      rustup.enable = lib.mkEnableOption "Rustup persist";
    };
    config =
      { value, ... }:
      lib.mkIf value.enable {
        directories = lib.mkMerge [
          (lib.mkIf value.cargo.enable [ ".cargo" ])
          (lib.mkIf value.rustup.enable [ ".rustup" ])
        ];
      };
  };
}
