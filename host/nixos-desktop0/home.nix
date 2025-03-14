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
    home.nixvim.full
    home.nixvim.complete.with-icons
    home.nixvim.gui.neovide.default
  ];

  develop = {
    nix = {
      enable = true;
      editor = {
        vscode.nix-ide.enable = true;
        nixvim.enable = true;
      };
      browser.firefox = {
        enable = true;
        profiles.default.enable = true;
      };
    };
  };

  home.packages = with pkgs; [
    git-annex

    gopass

    wl-clipboard

    vlc
  ];

  services.gpg-agent.pinentryPackage = pkgs.pinentry-all;

  programs.nixvim = {
    autoCmd = [
      {
        event = [ "VimLeave" ];
        pattern = [ "*" ];
        command = "set guicursor=a:ver25";
      }
    ];
  };
}
