{ pkgs, suites, ... }:
{
  imports = [
    suites.develop.home
  ];

  develop = {
    markdown = {
      enable = true;
      editor = {
        vscode.enable = true;
        nixvim.enable = true;
      };
    };
  };
}
