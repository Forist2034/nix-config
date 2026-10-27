{
  persist,
  lib,
  options,
  vscodium,
  ...
}:
{
  system = persist.user.mkModule {
    name = "ocaml";
    options = {
      enable = lib.mkEnableOption "OCaml";
    };
    config = { value, ... }: lib.mkIf value.enable { directories = [ ".opam" ]; };
  };
}
