{
  options,
  persist,
  lib,
  vscodium,
  ...
}:
{
  system = persist.user.mkModule {
    name = "javascript";
    options = {
      enable = lib.mkEnableOption "Javascript";
      yarn.enable = options.mkDisableOption "Yarn";
      pnpm.enable = options.mkDisableOption "Pnpm";
    };
    config =
      { value, ... }:
      lib.mkIf value.enable {
        directories = lib.mkMerge [
          [ ".npm" ]
          (lib.mkIf value.yarn.enable [
            ".yarn"
            ".cache/yarn"
          ])
          (lib.mkIf value.pnpm.enable [
            ".cache/pnpm"
            ".local/share/pnpm/store"
          ])
        ];
      };
  };

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.javascript = {
          enable = mkEnableOption "JavaScript environment";

          env = {
            enable = options.mkDisableOption "JavaScript build tools";

            yarn.enable = options.mkDisableOption "Yarn package manager";
            pnpm.enable = options.mkDisableOption "Pnpm package manager";
          };

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium JavaScript support";
            nixvim.enable = mkEnableOption "Nixvim JavaScript support";
          };
        };
      };

      config =
        let
          cfg = config.develop.javascript;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.nodejs
            (lib.mkIf cfg.env.yarn.enable pkgs.yarn)
            (lib.mkIf cfg.env.pnpm.enable pkgs.pnpm)
          ];

          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscodium.enable || editor.nixvim.enable;
              editor = {
                vscodium = lib.mkIf editor.vscodium.enable {
                  enable = true;
                  profiles = vscodium.profile.mkEnableConfig editor.vscodium.profiles {
                    enable = true;
                    languages = {
                      javascript = true;
                      javascriptreact = true;
                    };
                  };
                };
                nixvim = lib.mkIf editor.nixvim.enable {
                  enable = true;
                  languages = {
                    javascript = true;
                    javascriptreact = true;
                  };
                };
              };
            };
        };
    };
}
