let
  bat =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.bat ];
      environment.etc."bat/config".text = ''
        --theme=OneHalfDark
      '';
    };
  htop =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.htop ];
      environment.etc."htoprc".source = ./htoprc;
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
    { pkgs, ... }:
    {
      imports = [
        bat
        htop
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

  inherit bat htop;
}
