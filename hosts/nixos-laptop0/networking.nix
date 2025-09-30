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
              uuid = "c11d3ef2-9e15-49db-bc15-a189c6e70689";
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
            uuid = "601955a1-c037-427e-b7e4-1ff12715b445";
          };
        };
      };
    }
    (locations.loc0.config.networking.networkmanager.basic {
      hostId = 2;
      connectionUuids = {
        loc0-lan-wlan = "f5aef23d-684b-4a6a-8d67-fd7fc572c5b7";
        loc0-lan-wlan-dhcp_dns = "d00f8e93-f3c0-4368-970b-21e8b0bc6743";
      };
    })
    (locations.loc1.config.networking.networkmanager.basic {
      connectionUuids = {
        loc1-lan-wlan = "f30b24cb-f8e9-4386-9bdc-7a7cf16778d1";
        loc1-lan-wlan-dhcp_dns = "e63b5bc8-570a-4365-8d4e-b0769692db37";
      };
    })
  ];

  specialisation = {
    loc0.configuration =
      { ... }:
      {
        networking.networkmanager = locations.loc0.config.networking.networkmanager.extra {
          hostId = 2;
          connectionUuids = {
            loc0-lan-ethernet = "fbd67eaf-be2d-47fb-855e-d694c27ec525";
            loc0-lan-ethernet-dhcp_dns = "7732c385-ecb8-4485-a944-b749076edd9d";
            loc0-trusted-vlan = "d8b22ce6-573f-43ce-ab95-8d94e7b3e580";
            loc0-management-vlan = "29529d34-5d74-40e1-a0de-2ed858cbf842";
            loc0-management-ethernet = "edfa6be5-56e8-4558-9f61-c16b00991ba9";
          };
        };

        networking.firewall = {
          allowedTCPPorts = [
            8192
            16384
          ];
        };
      };
  };
}
