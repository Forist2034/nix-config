{ devLib, ... }:
let
  name = "rocq";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Rocq";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }:
      let
        server = pkgs.coqPackages.vscoq-language-server;
      in
      {
        extensions = [ pkgs.vscode-extensions.maximedenes.vscoq ];
        userSettings = {
          "vscoq.path" = "${server}/bin/vscoqtop";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      extraPlugins = [ pkgs.vimPlugins.Coqtail ];
      globals = {
        loaded_coqtail = 1;
        "coqtail#supported" = 0;
      };
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
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.rocq-core
        pkgs.coq
      ];
    }
  );
}
