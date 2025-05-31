lib: with lib; {
  inherit lib;

  modules = {
    importWithLibs = libs: paths: builtins.map (p: (import p) libs) paths;
  };

  options = {
    mkDisableOption =
      description:
      lib.mkOption {
        type = lib.types.bool;
        default = true;
        inherit description;
      };
  };

  ssh = {
    mkHostConfig =
      {
        name,
        hostname ? null,
        hostKeys,
      }:
      let
        knownHosts = builtins.toFile "${name}.keys" (
          builtins.concatStringsSep "\n" (builtins.map (k: "${name} ${k}") hostKeys)
        );
      in
      ''
        Host ${name}
          Protocol 2
          ${if hostname != null then "Hostname ${hostname}" else ""}
          StrictHostKeyChecking yes
          PubkeyAuthentication yes
          PreferredAuthentications publickey
          HostKeyAlias ${name}
          GlobalKnownHostsFile ${knownHosts}
      '';
  };

  firefox = {
    profile = {
      mkOption =
        options:
        lib.mkOption {
          type = types.attrsOf (types.submodule { inherit options; });
          default = { };
        };

      mkConfig = fun: config: builtins.mapAttrs (name: value: fun value) config;
    };
  };

  vscode =
    let
      profile =
        let
          mkOption =
            options:
            lib.mkOption {
              type = types.attrsOf (types.submodule { inherit options; });
              default = {
                default.enable = true;
              };
            };
          mkConfig = config: fun: builtins.mapAttrs (name: value: fun value) config;
        in
        {
          inherit mkOption;
          mkEnableOption =
            desc:
            mkOption {
              enable = lib.mkEnableOption desc;
            };
          inherit mkConfig;
          mkEnableConfig = config: cfg: mkConfig config (value: lib.mkIf value.enable cfg);
        };
    in
    {
      inherit profile;
      mkSimpleOption = desc: {
        enable = lib.mkEnableOption desc;
        profiles = profile.mkEnableOption desc;
      };
      mkSimpleConfig =
        config: fun:
        lib.mkIf config.enable {
          profiles = profile.mkEnableConfig config.profiles fun;
        };
    };

  persist = {
    system =
      let
        mkOption =
          options:
          lib.mkOption {
            type = types.attrsOf (
              types.submodule {
                inherit options;
              }
            );
          };
        mkConfig =
          fun: config:
          lib.mkMerge (
            builtins.map (value: {
              "${value.persistStorageRoot}" = fun value;
            }) (builtins.attrValues config.persistence)
          );
      in
      {
        inherit mkOption mkConfig;

        mkModule =
          {
            name,
            options,
            config,
          }@mod:
          { config, lib, ... }@args:
          {
            options.persistence = mkOption { ${name} = options; };
            config = {
              environment.persistence = mkConfig (value: mod.config (args // { value = value.${name}; })) config;
            };
          };
      };

    user =
      let
        mkOption =
          options:
          lib.mkOption {
            type = types.attrsOf (
              types.submodule {
                options.users = lib.mkOption { type = types.attrsOf (types.submodule { inherit options; }); };
              }
            );
          };
        mkConfig =
          fun: config:
          lib.mkMerge (
            builtins.map (value: {
              "${value.persistStorageRoot}" = {
                users = builtins.mapAttrs (user: value: fun value) value.users;
              };
            }) (builtins.attrValues config.persistence)
          );
      in
      {
        inherit mkOption mkConfig;

        mkModule =
          {
            name,
            options,
            config,
          }@mod:
          { config, lib, ... }@input:
          {
            options = {
              persistence = mkOption { ${name} = options; };
            };
            config = {
              environment.persistence = mkConfig (value: mod.config (input // { value = value.${name}; })) config;

              init-shared-persist = builtins.mapAttrs (
                _: value:
                lib.mkIf value.share.enable {
                  users = builtins.mapAttrs (
                    user: value: mod.config (input // { value = value.${name}; })
                  ) value.users;
                }
              ) config.persistence;
            };
          };
      };
  };
}
