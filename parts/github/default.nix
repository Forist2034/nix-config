{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "gh";
          options = {
            enable = lib.mkEnableOption "gh";
          };
          config = { value, ... }: lib.mkIf value.enable { files = [ ".config/gh/hosts.yml" ]; };
        };
      };
      profiles = {
        ssh_config =
          { ... }:
          let
            keys = builtins.fromJSON (builtins.readFile ./ssh_keys.json);
            toKnownHosts =
              host:
              builtins.toFile "${host}.keys" (
                builtins.concatStringsSep "\n" (builtins.map (key: "${host} ${key}") keys)
              );
          in
          {
            programs.ssh = {
              extraConfig =
                ''
                  Host ssh.github.com
                    Port 443
                    GlobalKnownHostsFile ${toKnownHosts "ssh.github.com"}

                  Host github.com
                    GlobalKnownHostsFile ${toKnownHosts "github.com"}
                ''
                + builtins.readFile ./ssh_config;
            };
          };
      };
    in
    {
      inherit modules profiles;

      default =
        { ... }:
        {
          imports = [
            modules.persist
            profiles.ssh_config
          ];
        };
    };

  home =
    let
      profiles = {
        default =
          { ... }:
          {
            programs.gh = {
              enable = true;
              settings = {
                git_protocol = "ssh";
              };
            };
          };
      };
    in
    {
      inherit profiles;

      default = profiles.default;
    };
}
