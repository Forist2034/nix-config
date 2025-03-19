{
  default =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          cascadia-code
        ];
        fontconfig = {
          defaultFonts = {
            monospace = [
              "Cascadia Code"
              "Cascadia Code NF"
            ];
          };
        };
      };
    };
}
