{ private, local-lib, ... }:
let
  privateCfg = private.locations.loc0;
  toDhcpDns = local-lib.networkmanager.profile.toDhcpDns;

  networks = {
    lan = rec {
      vlan.id = 1024 + 64;
      wlan = {
        inherit (privateCfg.networks.lan.wlan) ssid;
      };

      config = {
        networkmanager = {
          ethernet =
            {
              hostId,
              devId ? 1,
              uuid,
            }:
            {
              connection = {
                id = "Loc0-Lan-Ethernet";
                inherit uuid;
                type = "ethernet";
                autoconnect = true;
              };
              ethernet = {
                cloned-mac-address = "permanent";
              };
              ipv4 = {
                method = "manual";
                address1 = "10.64.${builtins.toString hostId}.${builtins.toString devId}/16,10.64.0.1";
              };
              ipv6 = {
                method = "auto";
                ignore-auto-dns = true;
              };
            };
          wlan =
            {
              hostId,
              devId ? 2,
              uuid,
            }:
            {
              connection = {
                id = "Loc0-Lan-Wlan";
                inherit uuid;
                type = "wifi";
                autoconnect = false;
              };
              wifi = {
                mode = "infrastructure";
                inherit (wlan) ssid;
                cloned-mac-address = "permanent";
              };
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk = "$LOC0_LAN_WLAN_PSK";
              };
              ipv4 = {
                method = "manual";
                address1 = "10.64.${builtins.toString hostId}.${builtins.toString devId}/16,10.64.0.1";
              };
              ipv6 = {
                method = "auto";
                ignore-auto-dns = true;
              };
            };
        };
      };
    };
    trusted = rec {
      vlan.id = 1024 + 16;

      config = {
        networkmanager = {
          vlan =
            {
              hostId,
              devId ? 1,
              uuid,
              parent,
            }:
            {
              connection = {
                id = "Loc0-Trusted-Vlan";
                inherit uuid;
                type = "vlan";
                autoconnect = false;
              };
              vlan = {
                inherit (vlan) id;
                inherit parent;
              };
              ipv4 = {
                method = "manual";
                address1 = "10.16.${builtins.toString hostId}.${builtins.toString devId}/16";
              };
              ipv6.method = "disabled";
            };
        };
      };
    };
    dmz = {
      vlan.id = 1024 + 32;
    };
    management = rec {
      vlan.id = 1024;

      config = {
        networkmanager = {
          vlan =
            {
              hostId,
              devId ? 1,
              uuid,
              parent,
            }:
            {
              connection = {
                id = "Loc0-Management-Vlan";
                inherit uuid;
                type = "vlan";
                autoconnect = false;
                permissions = "user:reid:";
              };
              vlan = {
                inherit (vlan) id;
                inherit parent;
              };
              ipv4 = {
                method = "manual";
                address1 = "10.0.${builtins.toString hostId}.${builtins.toString devId}/16";
              };
              ipv6.method = "disabled";
            };
          ethernet =
            {
              hostId,
              devId ? 2,
              uuid,
            }:
            {
              connection = {
                id = "Loc0-Management-Ethernet";
                inherit uuid;
                type = "ethernet";
                autoconnect = false;
                permissions = "user:reid:";
              };
              ethernet = {
                cloned-mac-address = "permanent";
              };
              ipv4 = {
                method = "manual";
                address1 = "10.0.${builtins.toString hostId}.${builtins.toString devId}/16";
                may-fail = false;
              };
              ipv6.method = "disabled";
            };
        };
      };
    };
  };
in
{
  inherit networks;

  config = {
    networking.networkmanager = {
      basic =
        { hostId, connectionUuids }:
        {
          ensureProfiles = {
            environmentFiles = [
              "/nix/secrets/network/loc0.env"
            ];
            profiles = rec {
              loc0-lan-wlan = networks.lan.config.networkmanager.wlan {
                inherit hostId;
                uuid = connectionUuids.loc0-lan-wlan;
              };
              loc0-lan-wlan-dhcp_dns = toDhcpDns loc0-lan-wlan {
                uuid = connectionUuids.loc0-lan-wlan-dhcp_dns;
                ipv4.dns = "10.64.0.1";
              };
            };
          };
        };
      extra =
        {
          hostId,
          connectionUuids,
          ethDevice ? null,
        }:
        let
          loc0-lan-ethernet =
            let
              cfg = networks.lan.config.networkmanager.ethernet {
                inherit hostId;
                uuid = connectionUuids.loc0-lan-ethernet;
              };
            in
            if ethDevice == null then
              cfg
            else
              cfg
              // {
                connection = cfg.connection // {
                  interface-name = ethDevice;
                };
              };
          vlanParent = if ethDevice == null then loc0-lan-ethernet.connection.uuid else ethDevice;
        in
        {
          ensureProfiles = {
            profiles = {
              inherit loc0-lan-ethernet;
              loc0-lan-ethernet-dhcp_dns = toDhcpDns loc0-lan-ethernet {
                uuid = connectionUuids.loc0-lan-ethernet-dhcp_dns;
                ipv4.dns = "10.64.0.1";
              };

              loc0-trusted-vlan = networks.trusted.config.networkmanager.vlan {
                inherit hostId;
                uuid = connectionUuids.loc0-trusted-vlan;
                parent = vlanParent;
              };
              loc0-management-vlan = networks.management.config.networkmanager.vlan {
                inherit hostId;
                uuid = connectionUuids.loc0-management-vlan;
                parent = vlanParent;
              };
              loc0-management-ethernet = networks.management.config.networkmanager.ethernet {
                inherit hostId;
                uuid = connectionUuids.loc0-management-ethernet;
              };
            };
          };
        };
    };
  };
}
