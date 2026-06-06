{
  mkHomeModule,
  options,
  vscodium,
  ...
}:
{
  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        develop.typescript = {
          enable = mkEnableOption "TypeScript environment";

          env.enable = options.mkDisableOption "TypeScript build tools";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium TypeScript support";
            helix.enable = mkEnableOption "Helix TypeScript support";
            nixvim.enable = mkEnableOption "Nixvim TypeScript support";
          };
        };
      };

      config =
        let
          cfg = config.develop.typescript;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [ pkgs.typescript ];

          develop.prettier =
            let
              editor = cfg.editor;
            in
            {
              enable = editor.vscodium.enable || editor.nixvim.enable;
              editor = {
                vscodium = lib.mkIf editor.vscodium.enable {
                  enable = true;
                  profiles = vscodium.profile.mkEnableConfig editor.vscodium {
                    enable = true;
                    languages = {
                      typescript = true;
                      typescriptreact = true;
                    };
                  };
                };
                nixvim = lib.mkIf editor.nixvim.enable {
                  enable = true;
                  languages = {
                    typescript = true;
                    typescriptreact = true;
                  };
                };
              };
            };

          programs.helix = lib.mkIf cfg.editor.helix.enable {
            extraPackages = [ pkgs.nodePackages.typescript-language-server ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              lsp.servers.ts_ls = {
                enable = true;
              };
            };
          };
        };
    };
}
