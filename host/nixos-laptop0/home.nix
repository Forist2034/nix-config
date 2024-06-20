{
  inputs,
  pkgs,
  home,
  modules,
  ...
}:
{
  imports = [
    home.vscode.default

    home.gpg
    home.gh
    home.thunderbird

    modules.develop.home

    inputs.nixvim.homeManagerModules.nixvim
    home.nixvim.base
  ];

  develop = {
    nix = {
      enable = true;
      editor = {
        vscode.nix-ide.enable = true;
      };
      browser.firefox = {
        enable = true;
        profiles.default.enable = true;
      };
    };
  };

  home.packages = with pkgs; [ gopass ];

  programs.bash.enable = true;
}
