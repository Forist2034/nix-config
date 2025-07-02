{ lib, local-lib, ... }:
{
  networking.networkmanager = {
    enable = true;
    appendNameservers = [
      "1.0.0.1"
      "1.1.1.1"
    ];
    connectionConfig = {
      "ipv6.ip6-privacy" = 2;
      "ipv6.addr-gen-mode" = "stable-privacy";
    };
    wifi = {
      macAddress = "stable";
    };
    ethernet = {
      macAddress = "stable";
    };

    ensureProfiles = {
      environmentFiles = [
        "/nix/secrets/network/loc0.env"
      ];
      profiles =
        let
          toDhcpDns = local-lib.networkmanager.profile.toDhcpDns;
        in
        rec {
          loc0-lan-ethernet = {
            connection = {
              id = "Loc0-Lan-Ethernet";
              uuid = "fbd67eaf-be2d-47fb-855e-d694c27ec525";
              type = "ethernet";
              autoconnect = lib.mkDefault false;
            };
            ethernet = {
              assigned-mac-address = "permanent";
            };
            ipv4 = {
              method = "manual";
              address1 = "192.168.8.33/24,192.168.8.1";
            };
            ipv6 = {
              method = "auto";
              ignore-auto-dns = true;
            };
          };
          loc0-lan-ethernet-dhcp_dns = toDhcpDns loc0-lan-ethernet {
            uuid = "7732c385-ecb8-4485-a944-b749076edd9d";
            ipv4.dns = "192.168.8.1";
          };

          loc0-lan-wlan = {
            connection = {
              id = "Loc0-Lan-Wlan";
              uuid = "f5aef23d-684b-4a6a-8d67-fd7fc572c5b7";
              type = "wifi";
              autoconnect = false;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$LOC0_LAN_WLAN_SSID";
              assigned-mac-address = "permanent";
            };
            wifi-security = {
              key-mgmt = "wpa-psk";
              psk = "$LOC0_LAN_WLAN_PSK";
            };
            ipv4 = {
              method = "manual";
              address1 = "192.168.8.34/24,192.168.8.1";
            };
            ipv6 = {
              method = "auto";
              ignore-auto-dns = true;
            };
          };
          loc0-lan-wlan-dhcp_dns = toDhcpDns loc0-lan-wlan {
            uuid = "d00f8e93-f3c0-4368-970b-21e8b0bc6743";
            ipv4.dns = "192.168.8.1";
          };

          loc0-trusted-vlan = {
            connection = {
              id = "Loc0-Trusted-Vlan";
              uuid = "d8b22ce6-573f-43ce-ab95-8d94e7b3e580";
              type = "vlan";
              autoconnect = false;
            };
            vlan = {
              id = 64;
              parent = loc0-lan-ethernet.connection.uuid;
            };
            ipv4 = {
              method = "manual";
              address1 = "192.168.64.33/24";
            };
            ipv6 = {
              method = "disabled";
            };
          };
          loc0-management-ethernet = {
            connection = {
              id = "Loc0-Management-Ethernet";
              uuid = "edfa6be5-56e8-4558-9f61-c16b00991ba9";
              type = "ethernet";
              autoconnect = false;
              permissions = "user:reid:";
            };
            ethernet = {
              assigned-mac-address = "permanent";
            };
            ipv4 = {
              method = "manual";
              address1 = "192.168.128.33/24";
              may-fail = false;
            };
            ipv6 = {
              method = "disabled";
            };
          };

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
  };

  specialisation = {
    loc0.configuration =
      { ... }:
      {
        networking.networkmanager.ensureProfiles = {
          profiles = {
            loc0-lan-ethernet = {
              connection.autoconnect = true;
            };
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
