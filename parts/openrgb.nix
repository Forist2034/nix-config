{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.system.mkModule {
          name = "openrgb";
          options = {
            enable = lib.mkEnableOption "OpenRGB support";
          };
          config =
            { value, lib, ... }:
            lib.mkIf value.enable {
              directories = [
                "/var/lib/OpenRGB"
              ];
            };
        };
      };
    in
    {
      inherit modules;

      default =
        { pkgs, ... }:
        {
          imports = [ modules.persist ];

          services.hardware.openrgb = {
            enable = true;

            # TODO: use upstream package when updated
            package = pkgs.openrgb.overrideAttrs (
              finalAttrs: prevAttrs: {
                version = "candidate_1.0rc1";
                src = pkgs.fetchFromGitLab {
                  owner = "CalcProgrammer1";
                  repo = "OpenRGB";
                  rev = "release_candidate_1.0rc1";
                  hash = "sha256-jKAKdja2Q8FldgnRqOdFSnr1XHCC8eC6WeIUv83e7x4=";
                };

                patches = [ ];

                postPatch = ''
                  patchShebangs scripts/build-udev-rules.sh
                  substituteInPlace scripts/build-udev-rules.sh \
                    --replace-fail "/usr/bin/env chmod" "${pkgs.coreutils}/bin/chmod"
                '';
              }
            );
          };
        };
    };
}
