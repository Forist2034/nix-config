{
  dev =
    { pkgs, ... }:
    {
      fonts.packages = [ pkgs.cascadia-code ];
    };

  nerdfonts.cascadia =
    { pkgs, ... }:
    {
      fonts.packages = [ (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; }) ];
    };
}
