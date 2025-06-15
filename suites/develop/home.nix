{
  inputs,
  pkgs,
  parts,
  # legacy modules
  home,
  modules,
  ...
}:
{
  imports = [
    parts.gpg.home.default
    parts.github.home.default
    parts.thunderbird.home.default

    modules.develop.home

    parts.vscode.home.default

    inputs.nixvim.homeManagerModules.nixvim
    home.nixvim.full
    home.nixvim.complete.with-icons
    home.nixvim.gui.neovide.default
  ];

  develop = {
    nix = {
      enable = true;
      editor = {
        vscode.enable = true;
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

    ripgrep-all
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
}
