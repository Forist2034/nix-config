{ devLib, local-lib, ... }:
let
  name = "zig";
  mkEnableModule = devLib.mkEnableModule {
    inherit name;
    descName = "Zig";
  };
in
{
  inherit name;
  submodules = {
    firefox.global =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        options = {
          cfglib.develop.zig = with lib; {
            enable = mkEnableOption "Zig support";
            docs = {
              zig.enable = local-lib.options.mkDisableOption "Zig lang reference";
            };
          };
        };
        config =
          let
            cfg = config.cfglib.develop.zig;
          in
          lib.mkIf cfg.enable {
            policies.ManagedBookmarks = lib.mkIf cfg.docs.zig.enable [
              {
                name = "Zig Language Reference";
                url = "file://${pkgs.zig.doc}/share/doc/zig-${pkgs.zig.version}/html/langref.html";
              }
            ];
          };
      };

    helix = mkEnableModule ({ pkgs, ... }: { extraPackages = [ pkgs.zls ]; });

    vscodium = mkEnableModule (
      { pkgs, ... }: {
        extensions = [ pkgs.vscode-extensions.ziglang.vscode-zig ];
        userSettings = {
          "zig.initialSetupDone" = true;
          "zig.checkForUpdate" = false;
          "zig.zls.path" = "${pkgs.zls}/bin/zls";
          "zig.path" = "${pkgs.zig}/bin/zig";
        };
      }
    );
  };

  nixvim = mkEnableModule (
    { ... }: {
      plugins = {
        lsp.servers.zls = {
          enable = true;
        };
        zig.enable = true;
      };
    }
  );

  home = mkEnableModule (
    { pkgs, ... }:
    {
      home.packages = [ pkgs.zig ];
    }
  );
}
