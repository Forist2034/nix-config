{ devLib, ... }:
let
  name = "verilog";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Verilog";
  };
in
{
  inherit name;
  submodules = {
    # TODO: add formatter in vscodium
    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.mshr-h.veriloghdl ];
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        none-ls.sources = {
          formatting.verible_verilog_format.enable = true;
        };
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }: {
      home.packages = [
        pkgs.gtkwave
        pkgs.verilator
      ];
    }
  );
}
