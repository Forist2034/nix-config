{ lib, ... }:
{
  networking.networkmanager = {
    enable = true;
    insertNameservers = [
      "1.0.0.1"
      "1.1.1.1"
    ];
    connectionConfig = {
      "ipv6.ip6-privacy" = 2;
      "ipv6.addr-gen-mode" = "stable-privacy";
    };

    ensureProfiles = {
      environmentFiles = [
        "/nix/secrets/network/loc0.env"
      ];
      profiles = rec {
        loc0-lan-ethernet = {
          connection = {
            id = "Loc0-Lan-Ethernet";
            uuid = "fbd67eaf-be2d-47fb-855e-d694c27ec525";
            type = "ethernet";
            autoconnect = lib.mkDefault false;
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.8.33/24,192.168.8.1";
          };
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
            ip6-privacy = 2;
          };
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
            addr-gen-mode = "stable-privacy";
            ip6-privacy = 2;
          };
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
            id = "Wired Connection";
            uuid = "c11d3ef2-9e15-49db-bc15-a189c6e70689";
            type = "ethernet";
            autoconnect = false;
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            method = "auto";
            addr-gen-mode = "stable-privacy";
            ip6-privacy = 2;
          };
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
