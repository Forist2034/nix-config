let
  base =
    { pkgs, ... }:
    {
      programs.nixvim = {
        globals = {
          neovide_cursor_animation_length = 0;
          neovide_transparency = 0.8;
        };
        opts = {
          guifont = "Cascadia Code PL:h10";
        };
      };

      home.packages = [ pkgs.neovide ];
    };
in
{
  inherit base;
  default = base;
}
