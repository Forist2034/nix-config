let
  nixvim = import ./nixvim/nixvim.nix;
in
{ inputs, ... }:
{
  inherit nixvim;

  home =
    let
      profiles = {
        neovide = { pkgs, ... }: {
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
        };
      };
    in
    {
      inherit profiles;

      default = { ... }: {
        imports = [
          inputs.nixvim.homeModules.default

          profiles.neovide
        ];

        programs.nixvim = {
          enable = true;
          nixpkgs.source = inputs.nixpkgs;
          imports = [ nixvim.default ];
        };
      };
    };
}
