{ pkgs, suites, ... }:
{
  imports = [
    suites.develop.home
  ];

  develop = {
    markdown = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
  };
}
