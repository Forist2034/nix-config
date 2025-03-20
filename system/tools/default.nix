let
  bat =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.bat ];
      environment.etc."bat/config".text = ''
        --theme=OneHalfDark
      '';
    };
in
{
  min =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        coreutils
        moreutils
      ];
    };
  base =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        git
        neovim
        curl
        wget
        unzip
        lzip
      ];
    };

  admin =
    { pkgs, parts, ... }:
    {
      imports = [
        bat
        parts.htop.system.default
      ];
      environment.systemPackages = with pkgs; [
        eza
        fd
        ripgrep
        duf
        du-dust
        zellij
      ];
    };

  inherit bat;
}
