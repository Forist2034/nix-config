{ devLib, ... }:
let
  name = "python";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Python";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = with pkgs.vscode-extensions; [
          ms-python.python
          ms-python.debugpy
          charliermarsh.ruff
        ];
        userSettings = {
          "python.languageServer" = "Jedi";
          "ruff.path" = [ "${pkgs.ruff}/bin/ruff" ];
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      plugins = {
        lsp.servers.pylsp = {
          enable = true;
          settings.plugins = {
            ruff = {
              enabled = true;
              executable = "${pkgs.ruff}/bin/ruff";
            };
          };
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [
        pkgs.python3
        pkgs.ruff
      ];
    }
  );
}
