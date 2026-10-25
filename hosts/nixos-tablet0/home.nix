{ pkgs, suites, ... }:
{
  imports = [
    suites.develop.home
  ];

  develop = {
    cpp = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    markdown = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    nushell = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    rust = {
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
    toml = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
  };
}
