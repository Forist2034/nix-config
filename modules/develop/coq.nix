{ options, vscode, ... }:
{
  home =
    {
      config,
      pkgs,
      inputs,
      lib,
      info,
      ...
    }:
    {
      options = with lib; {
        develop.coq = {
          enable = mkEnableOption "Coq Support";

          env.enable = options.mkDisableOption "Coq build tools";

          editor = {
            vscode = vscode.mkSimpleOption "VSCode Rocq support";
            nixvim = {
              enable = mkEnableOption "Neovim nix coq";
              coqtail.enable = mkEnableOption "Use Coqtail for proof";
            };
          };
        };
      };

      config =
        let
          cfg = config.develop.coq;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.coq
          ];

          programs.vscode =
            let
              server = pkgs.coqPackages.vscoq-language-server;
            in
            vscode.mkSimpleConfig cfg.editor.vscode {
              extensions = pkgs.nix4vscode.forVscode [ "maximedenes.vscoq.${server.version}" ];
              userSettings = {
                "vscoq.path" = "${server}/bin/vscoqtop";
              };
            };

          programs.nixvim =
            let
              cfgVim = cfg.editor.nixvim;
            in
            lib.mkIf cfgVim.enable (
              lib.mkMerge [
                { extraPlugins = [ pkgs.vimPlugins.Coqtail ]; }
                (lib.mkIf cfgVim.coqtail.enable {
                  keymaps =
                    let
                      mkMap = key: action: {
                        inherit key;
                        action = "<Plug>${action}";
                        mode = [
                          "n"
                          "i"
                        ];
                      };
                    in
                    [
                      (mkMap "<M-Up>" "CoqUndo")
                      (mkMap "<M-Down>" "CoqNext")
                      (mkMap "<M-Right>" "CoqToLine")
                    ];
                })
                (lib.mkIf (!cfgVim.coqtail.enable) {
                  globals = {
                    loaded_coqtail = 1;
                    "coqtail#supported" = 0;
                  };
                })
              ]
            );
        };
    };
}
