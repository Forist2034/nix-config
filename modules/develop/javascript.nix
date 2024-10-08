{
  options,
  persist,
  lib,
  ...
}:
{
  system = persist.user.mkModule {
    name = "javascript";
    options = {
      enable = lib.mkEnableOption "Javascript";
      yarn.enable = options.mkDisableOption "Yarn";
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
          };

          editor = {
            vscode.enable = mkEnableOption "VSCode JavaScript support";
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
          ];

          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscode.enable || editor.nixvim.enable;
              editor = {
                vscode = lib.mkIf editor.vscode.enable {
                  enable = true;
                  languages = {
                    javascript = true;
                    javascriptreact = true;
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
