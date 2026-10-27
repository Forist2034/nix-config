{ devLib, ... }:
let
  name = "lean";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Lean";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = pkgs.nix4vscode.forOpenVsx [
          "leanprover.lean4"
        ];
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lean = {
          enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [ pkgs.lean4 ];
    }
  );
}
