{ persist, lib, ... }:
persist.user.mkModule {
  name = "gh";
  options = { enable = lib.mkEnableOption "gh"; };
  config = { value, ... }:
    lib.mkIf value.enable { files = [ ".config/gh/hosts.yml" ]; };
}
