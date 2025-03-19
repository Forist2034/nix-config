{
  default =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          cascadia-code
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
        ];
        fontconfig = {
          defaultFonts = {
            monospace = [
              "Cascadia Code"
              "Cascadia Code NF"
            ];
          };
          localConf = ''
            <include>${./fonts/cjk.conf}</include>
          '';
        };
      };
    };
}
