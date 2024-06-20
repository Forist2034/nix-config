{ persist, lib, ... }:
persist.user.mkModule {
  name = "gpg";
  options = {
    enable = lib.mkEnableOption "GnuPG persist";
  };
  config =
    { value, ... }:
    lib.mkIf value.enable {
      directories = [
        {
          directory = ".gnupg";
          mode = "0700";
        }
      ];
    };
}
