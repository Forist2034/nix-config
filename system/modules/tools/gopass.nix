{ persist, lib, ... }:
persist.user.mkModule {
  name = "gopass";
  options = { enable = lib.mkEnableOption "Gopass store"; };
  config = { value, ... }:
    lib.mkIf value.enable { directories = [ ".local/share/gopass/stores" ]; };
}
