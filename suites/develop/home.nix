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
    modules.develop.home

    parts.nushell.home.default
    parts.task.home.default
    parts.vscodium.home.default

    inputs.nixvim.homeModules.nixvim
    home.nixvim.full
    home.nixvim.complete.with-icons
    home.nixvim.gui.neovide.default
  ];

  develop = {
    nickel = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    nix = {
      enable = true;
      editor = {
        vscodium.enable = true;
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

    wl-clipboard

    vlc

    ripgrep-all
  ];
}
