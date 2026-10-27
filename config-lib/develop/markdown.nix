{ devLib, ... }:
let
  name = "markdown";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Markdown";
  };
in
{
  inherit name;
  submodules = {
    vscodium = mkEnableModule (
      { ... }: {
        cfglib.develop.prettier = {
          enable = true;
          languages.markdown = true;
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      cfglib.develop.prettier = {
        enable = true;
        languages.markdown = true;
      };
    }
  );
}
