{ devLib, local-lib, ... }:
let
  name = "latex";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "LaTex";
  };
in
{
  inherit name;
  submodules = {
    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.texlab ]; });

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.james-yu.latex-workshop ];
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.texlab = {
          enable = true;
        };
        vimtex = {
          enable = true;
        };
      };
    }
  );

  home =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = with lib; {
        cfglib.develop.latex = {
          enable = mkEnableOption "LaTex support";
          texlive = {
            full.enable = local-lib.options.mkDisableOption "Full texlive LaTex build tools";
          };
        };
      };

      config =
        let
          cfg = config.cfglib.develop.latex;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.texlive.full.enable [ pkgs.texlive.combined.scheme-full ];
        };
    };
}
