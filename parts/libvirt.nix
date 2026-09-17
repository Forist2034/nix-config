{ local-lib, lib, ... }:
{
  system =
    let
      modules = {
        persist = local-lib.persist.system.mkModule {
          name = "libvirt";
          options = {
            enable = lib.mkEnableOption "libvirt persist";
            swtpm.enable = local-lib.options.mkDisableOption "swtpm state";
          };
          config =
            { value, lib, ... }:
            lib.mkIf value.enable {
              directories = lib.mkMerge [
                [
                  "/var/lib/libvirt"
                ]
                (lib.mkIf value.swtpm.enable [
                  "/var/lib/swtpm-localca"
                ])
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

          virtualisation.libvirtd = {
            enable = true;
            onBoot = "ignore";
            qemu = {
              swtpm.enable = true;
              vhostUserPackages = [ pkgs.virtiofsd ];
            };
          };

          programs.virt-manager.enable = true;
        };
    };
}
