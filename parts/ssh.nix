{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "ssh";
          options = {
            enable = lib.mkEnableOption "SSH persist";
            keys = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "ssh keys to perserve";
            };
            knownHosts = lib.mkEnableOption "persist known_hosts file";
          };
          config =
            { value, ... }:
            let
              mkFile = f: {
                file = ".ssh/${f}";
                parentDirectory.mode = "0700";
              };
            in
            lib.mkIf value.enable (
              lib.mkMerge [
                {
                  files = builtins.concatMap (k: [
                    (mkFile k)
                    (mkFile "${k}.pub")
                  ]) value.keys;
                }
                (lib.mkIf value.knownHosts { files = [ (mkFile "known_hosts") ]; })
              ]
            );
        };
      };
    in
    {
      inherit modules;

      default = modules.persist;
    };
}
