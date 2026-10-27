{ devLib, ... }:
let
  name = "shell";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Shell";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.mads-hartmann.bash-ide-vscode ];
        userSettings = {
          "bashIde.shellcheckPath" = "${pkgs.shellcheck}/bin/shellcheck";
          "bashIde.shfmt.path" = "${pkgs.shfmt}/bin/shfmt";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { pkgs, ... }: {
      lsp.servers.bashls.enable = true;
      extraPackages = [
        pkgs.shfmt
        pkgs.shellcheck
      ];
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.shfmt
        pkgs.shellcheck
      ];
    }
  );
}
