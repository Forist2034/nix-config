{ options, ... }:
{
  id,
  name,
  env ? null,
  editor ? { },
  browser ? { },
  extra ? { },
}:
{
  config,
  pkgs,
  lib,
  ...
}@args:
{
  options = with lib; {
    develop.${id} =
      builtins.foldl' (acc: i: acc // i) { enable = mkEnableOption "${name} development"; }
        [
          (
            if env != null then
              {
                env = {
                  enable = options.mkDisableOption "${name} tools";
                } // (env.options or { });
              }
            else
              { }
          )

          (
            if editor != { } then
              {
                editor = builtins.foldl' (acc: i: acc // i) { } [
                  (
                    if editor ? vscode then
                      {
                        vscode = {
                          enable = mkEnableOption "VSCode ${name} support";
                        } // (editor.vscode.options or { });
                      }
                    else
                      { }
                  )

                  (
                    if editor ? helix then
                      {
                        helix = {
                          enable = mkEnableOption "Helix ${name} support";
                        } // (editor.helix.options or { });
                      }
                    else
                      { }
                  )

                  (
                    if editor ? nixvim then
                      {
                        nixvim = {
                          enable = mkEnableOption "Nixvim ${name} support";
                        } // (editor.nixvim.options or { });
                      }
                    else
                      { }
                  )
                ];
              }
            else
              { }
          )

          (
            if browser ? firefox then
              {
                browser.firefox = {
                  enable = mkEnableOption "${name} doc";
                } // (browser.options or { });
              }
            else
              { }
          )

          (extra.options or { })
        ];
  };

  config =
    let
      cfg = config.develop.${id};
    in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        (if env != null then env.config args cfg.env else { })

        (
          if browser ? firefox then
            {
              programs.firefox = lib.mkIf cfg.editor.firefox.enable (
                browser.firefox.config args cfg.browser.firefox
              );
            }
          else
            { }
        )

        (
          if editor ? helix then
            { programs.helix = lib.mkIf cfg.editor.helix.enable (editor.helix.config args cfg.editor.helix); }
          else
            { }
        )

        (
          if editor ? vscode then
            {
              programs.vscode = lib.mkIf cfg.editor.vscode.enable (editor.vscode.config args cfg.editor.vscode);
            }
          else
            { }
        )

        (
          if editor ? nixvim then
            {
              programs.nixvim = lib.mkIf cfg.editor.nixvim.enable (editor.nixvim.config args cfg.editor.nixvim);
            }
          else
            { }
        )

        (if extra ? config then extra.config args cfg else { })
      ]
    );
}
