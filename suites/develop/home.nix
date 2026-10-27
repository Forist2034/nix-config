{
  inputs,
  pkgs,
  cfglib,
  parts,
  config,
  # legacy modules
  home,
  ...
}:
{
  imports = [
    parts.nushell.home.default
    parts.task.home.default
    parts.direnv.home.default

    cfglib.programs.nixvim.home.default
    cfglib.programs.vscodium.home.default

    cfglib.develop.home
  ];

  cfglib.develop = {
    nickel.enable = true;
  };

  cfglib.programs.firefox = { ... }: {
    imports = [ cfglib.develop.submodules.firefox.global ];
    cfglib.develop = {
      nix = {
        enable = true;
        manuals.nix.package = config.nix.package;
      };
    };
  };

  programs.nixvim.imports = [
    {
      imports = [ cfglib.develop.nixvim ];
      cfglib.develop = {
        nickel.enable = true;
        nix.enable = true;
      };
    }
  ];

  programs.vscodium.profiles.default = { ... }: {
    imports = [ cfglib.develop.submodules.vscodium ];

    cfglib.develop = {
      nickel.enable = true;
      nix.enable = true;
    };
  };

  home.packages = with pkgs; [
    git-annex

    wl-clipboard

    vlc

    ripgrep-all
  ];
}
