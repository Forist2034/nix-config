let
  helix = {
    profiles.base = {
      settings = {
        theme = "catppuccin_frappe";
        editor = {
          cursor-shape = {
            insert = "bar";
          };
          rulers = [ 80 ];
        };
      };

    };
  };
in
{
  submodules = { inherit helix; };

  home =
    let
      modules = {
        submodule =
          {
            options,
            config,
            lib,
            pkgs,
            ...
          }:
          {
            options = {
              cfglib.programs.helix = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    inherit (options.programs.helix)
                      settings
                      languages
                      ignores
                      themes
                      extraConfig
                      extraPackages
                      ;
                  };
                };
                default = { };
              };
            };
            config = {
              cfglib.programs.helix = {
                _module.args = { inherit pkgs; };
              };

              programs.helix = {
                inherit (config.cfglib.programs.helix)
                  settings
                  languages
                  ignores
                  themes
                  extraConfig
                  extraPackages
                  ;
              };
            };
          };
      };
    in
    {
      inherit modules;

      default = { pkgs, ... }: {
        imports = [ modules.submodule ];

        cfglib.programs.helix = helix.profiles.base;
        programs.helix.enable = true;
      };
    };
}
