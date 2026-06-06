{
  local-lib,
  lib,
  ...
}:
let
  config = import ./config.nix;
in
{
  inherit config;

  system =
    let
      modules = {
        persist = local-lib.persist.user.mkModule {
          name = "firefox";
          options = {
            enable = lib.mkEnableOption "Persist firefox data";
            configPath = lib.mkOption {
              description = "firefox config path";
              type = lib.types.pathWith { };
              default = ".config/mozilla/firefox";
            };
            profiles = local-lib.firefox.profile.mkOption {
              enable = lib.mkEnableOption "Persist profile";
              bookmarks.enable = lib.mkEnableOption "Persist bookmarks";
              bookmarkbackups.enable = lib.mkEnableOption "Persist bookmark backups";
              account.enable = lib.mkEnableOption "Persist firefox account";
            };
          };
          config =
            { value, ... }:
            let
              configPath = value.configPath;
            in
            lib.mkIf value.enable (
              lib.mkMerge (
                builtins.attrValues (
                  builtins.mapAttrs (
                    name: value:
                    lib.mkIf value.enable (
                      lib.mkMerge [
                        (lib.mkIf value.bookmarks.enable {
                          files = [
                            "${configPath}/${name}/places.sqlite"
                            "${configPath}/${name}/places.sqlite-shm"
                            "${configPath}/${name}/places.sqlite-wal"
                          ];
                        })
                        (lib.mkIf value.bookmarkbackups.enable {
                          directories = [ "${configPath}/${name}/bookmarkbackups" ];
                        })
                        (lib.mkIf value.account.enable {
                          files = [
                            "${configPath}/${name}/key4.db"
                            "${configPath}/${name}/signedInUser.json"
                            "${configPath}/${name}/logins.json"
                          ];
                        })
                      ]
                    )
                  ) (value.profiles or { })
                )
              )
            );
        };
      };
    in
    {
      inherit modules;

      default = modules.persist;
    };

  home = {
    default =
      {
        inputs,
        lib,
        pkgs,
        info,
        ...
      }@args:
      {
        programs.firefox =
          let
            utils = inputs.browser-utils.packages.${info.system};
          in
          {
            enable = true;

            package = pkgs.firefox-devedition;

            configPath = "${args.config.xdg.configHome}/mozilla/firefox";
            policies = lib.mkMerge [
              config.policies.base
              {
                ExtensionSettings = {
                  "@testpilot-containers" =
                    let
                      extension = pkgs.fetchurl {
                        # UPDATE
                        url = "https://addons.mozilla.org/firefox/downloads/file/4733069/multi_account_containers-8.3.7.xpi";
                        hash = "sha256-f29e97EG0z0bmdLF5TogZdB/eEsYUv6bn3g5TptAUWU=";
                      };
                    in
                    {
                      installation_mode = "normal_installed";
                      install_url = "file://${extension}";
                      updates_disabled = true;
                    };
                };
              }
            ];

            nativeMessagingHosts = [ utils.browser-utils.ext ];

            profiles = {
              default = config.profiles.default // {
                isDefault = true;

                # dev edition needs default profile name be prefixed with dev-edition
                name = "dev-edition-default";
                path = "default";

                settings = {
                  "xpinstall.signatures.required" = false;
                };

                extensions = {
                  force = true;
                  packages = [ utils.history-extension ];
                  settings = {
                    "${utils.history-extension.addonId}".settings = {
                      root = "${args.config.home.homeDirectory}/Documents/browser-utils/history";
                    };
                  };
                };
              };
              test = config.profiles.base // {
                id = 1;
              };
            };
          };
      };

  };
}
