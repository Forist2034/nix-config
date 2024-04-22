{ persist, lib, ... }:
persist.user.mkModule {
  name = "ssh";
  options = { enable = lib.mkEnableOption "SSH persist"; };
  config = { value, ... }:
    lib.mkIf value.enable {
      directories = [{
        directory = ".ssh";
        mode = "0700";
      }];
    };
}
