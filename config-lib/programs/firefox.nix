let
  firefox = import ./firefox/firefox.nix;
in
{
  submodules = { inherit firefox; };

  home =
    let
      modules = {
        submodule =
          {
            options,
            config,
            lib,
            pkgs,
            ...
          }:
          {
            options = {
              cfglib.programs.firefox = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    inherit (options.programs.firefox)
                      policies
                      pkcs11Modules
                      nativeMessagingHosts
                      profiles
                      ;
                  };
                };
                default = { };
              };
            };
            config = {
              cfglib.programs.firefox = {
                _module.args = { inherit pkgs; };
              };
              programs.firefox = {
                inherit (config.cfglib.programs.firefox)
                  policies
                  pkcs11Modules
                  nativeMessagingHosts
                  profiles
                  ;
              };
            };
          };
      };
    in
    {
      inherit modules;

      default =
        { config, pkgs, ... }:
        {
          imports = [ modules.submodule ];

          cfglib.programs.firefox = { ... }: {
            imports = [ firefox.global.default ];
          };
          programs.firefox = {
            enable = true;
            package = pkgs.firefox-devedition;
            configPath = "${config.xdg.configHome}/mozilla/firefox";

            profiles.default = {
              isDefault = true;
              # dev edition needs default profile name be prefixed with dev-edition
              name = "dev-edition-default";
            };
          };
        };
    };
}
