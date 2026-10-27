{ pkgs, suites, ... }:
let
  devCfg = {
    cfglib.develop = {
      cpp.enable = true;
      markdown.enable = true;
      nushell.enable = true;
      rust.enable = true;
      toml.enable = true;
    };
  };
in

{
  imports = [
    suites.develop.home

    devCfg
  ];

  cfglib.programs.firefox = devCfg;

  programs.nixvim = {
    imports = [ devCfg ];
  };

  programs.vscodium = {
    profiles.default = devCfg;
  };

}
