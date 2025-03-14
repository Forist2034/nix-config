{
  inputs,
  pkgs,
  home,
  modules,
  parts,
  ...
}:
{
  imports = [
    home.vscode.default

    home.gpg
    home.gh
    home.thunderbird
    home.taskwarrior

    modules.develop.home

    inputs.nixvim.homeManagerModules.nixvim
    home.nixvim.full
    home.nixvim.complete.with-icons
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

  services.gpg-agent.pinentryPackage = pkgs.pinentry-all;

  home.packages = with pkgs; [
    git-annex

    gopass

    wireshark

    wl-clipboard
    xsel
    xclip

    nss.tools # for firefox certificate

    vlc
    rsibreak
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

  programs.firefox.profiles = {
    # no local cdn proxy, for account login
    upstream-cdn = parts.firefox.config.profiles.base // {
      id = 2;
    };
  };

  programs.bash.enable = true;
}
