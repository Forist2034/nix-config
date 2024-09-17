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

  services.gpg-agent.pinentryPackage = pkgs.pinentry-all;

  home.packages = with pkgs; [
    git-annex

    gopass
  ];

  programs.nixvim = {
    autoCmd = [
      {
        event = [ "VimLeave" ];
        pattern = [ "*" ];
        command = "set guicursor=a:ver25";
      }
    ];
  };

  programs.bash.enable = true;
}
