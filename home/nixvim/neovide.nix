let
  base =
    { pkgs, ... }:
    {
      programs.nixvim = {
        globals = {
          neovide_cursor_animation_length = 0;
          neovide_transparency = 0.8;
        };
      };

      programs.neovide = {
        enable = true;
        settings = {
          maximized = true;
          font = {
            normal = [ "monospace" ];
            size = 10;
          };
        };
      };

      home.packages = [ pkgs.neovide ];
    };
in
{
  inherit base;
  default = base;
}
