{ mkHomeModule, options, ... }: {
  home = mkHomeModule {
    id = "typescript";
    name = "TypeScript";

    env.config = { pkgs, ... }: cfg: { home.packages = [ pkgs.typescript ]; };

    editor = {
      helix.config = { pkgs, ... }:
        cfg: {
          languages.language-server.typescript-language-server = {
            command =
              "${pkgs.nodePackages.typescript-language-server}/bin/typescript-language-server";
          };
        };

      nixvim.config = { pkgs, ... }:
        cfg: {
          plugins = { lsp.servers.tsserver.enable = true; };
        };
    };
  };
}
