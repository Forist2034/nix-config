{ config, lib, ... }:
{
  options = with lib; {
    persistence = mkOption {
      type = types.attrsOf (
        types.submodule {
          options =
            let
              fileList = mkOption {
                type = types.listOf types.str;
                default = [ ];
              };
            in
            {
              files = fileList;
              directories = fileList;
              users = mkOption {
                type = types.attrsOf (
                  types.submodule {
                    options = {
                      files = fileList;
                      directories = fileList;
                    };
                  }
                );
              };
            };
        }
      );
    };
  };
  config = {
    environment.persistence = builtins.mapAttrs (path: value: {
      inherit (value) files directories;
      users = builtins.mapAttrs (user: value: { inherit (value) files directories; }) value.users;
    }) config.persistence;
  };
}
