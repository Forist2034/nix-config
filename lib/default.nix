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

  persist = {
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
          builtins.mapAttrs (path: value: {
            users = builtins.mapAttrs (user: value: fun value) value.users;
          }) config.persistence;
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
            };
          };
      };
  };
}
