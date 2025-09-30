{
  lib,
  locations,
  local-lib,
  ...
}:
let
  toDhcpDns = local-lib.networkmanager.profile.toDhcpDns;
in
{

  networking.networkmanager = lib.mkMerge [
    {
      enable = true;
      appendNameservers = [
        "1.0.0.1"
        "1.1.1.1"
      ];
      connectionConfig = {
        "connection.stable-id" = "\${CONNECTION}-\${BOOT}-\${DEVICE}";
        "ipv6.ip6-privacy" = 2;
        "ipv6.addr-gen-mode" = "stable-privacy";
      };
      wifi = {
        macAddress = "stable";
      };
      ethernet = {
        macAddress = "stable";
      };
      settings = {
        main = {
          no-auto-default = "*";
        };
      };

      ensureProfiles = {
        profiles = rec {
          external-ethernet = {
            connection = {
              id = "External-Ethernet";
              uuid = "6f6559dd-8a88-49a2-9062-f0e1bad2ef6e";
              type = "ethernet";
              autoconnect = false;
            };
            ipv4 = {
              method = "auto";
              ignore-auto-dns = true;
            };
            ipv6 = {
              method = "auto";
              ignore-auto-dns = true;
            };
          };
          external-ethernet-dhcp_dns = toDhcpDns external-ethernet {
            uuid = "12d54178-d1b2-4dcc-8bf1-ee38c94b9219";
          };
        };
      };
    }
    (locations.loc0.config.networking.networkmanager.basic {
      hostId = 4;
      connectionUuids = {
        loc0-lan-wlan = "347013a4-8e41-4cc0-ab5c-9028938ccddb";
        loc0-lan-wlan-dhcp_dns = "925a8a6b-7831-4aff-9dbf-5f3811127da9";
      };
    })
  ];

  specialisation = {
    loc0.configuration =
      { ... }:
      {
        networking.networkmanager = locations.loc0.config.networking.networkmanager.extra {
          hostId = 4;
          connectionUuids = {
            loc0-lan-ethernet = "a7caefa5-7c72-4f0e-8736-1d92b6a5b2d8";
            loc0-lan-ethernet-dhcp_dns = "33ec830e-e390-40fc-8fda-7c14ee264667";
            loc0-trusted-vlan = "d6dded62-a0ba-453b-9d7b-d0e6612b9f8c";
            loc0-management-vlan = "44202d57-c236-4974-ad04-358bd322c4ee";
            loc0-management-ethernet = "44bd97ed-7802-4367-9761-798612d10c09";
          };
        };
      };
  };
}
