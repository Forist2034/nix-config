{ options, vscodium, ... }:
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
        develop.verilog = {
          enable = mkEnableOption "Verilog environment";

          env.enable = options.mkDisableOption "Verilog tools";

          editor = {
            vscodium = vscodium.mkSimpleOption "VSCodium verilog support";
            nixvim.enable = mkEnableOption "Neovim verilog support";
          };
        };
      };

      config =
        let
          cfg = config.develop.verilog;
        in
        lib.mkIf cfg.enable {
          home.packages = lib.mkIf cfg.env.enable [
            pkgs.gtkwave
            pkgs.verilator
          ];

          # TODO: add formatter in vscodium
          programs.vscodium = vscodium.mkSimpleConfig cfg.editor.vscodium {
            extensions = [ pkgs.vscode-extensions.mshr-h.veriloghdl ];
          };

          programs.nixvim = lib.mkIf cfg.editor.nixvim.enable {
            plugins = {
              none-ls.sources = {
                formatting.verible_verilog_format.enable = true;
              };
            };
          };
        };
    };
}
