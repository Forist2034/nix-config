{
  dev =
    { pkgs, ... }:
    {
      fonts.packages = [ pkgs.cascadia-code ];
    };
}
