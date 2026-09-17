{ private, local-lib, ... }:
let
  privateCfg = private.locations.loc1;
  toDhcpDns = local-lib.networkmanager.profile.toDhcpDns;

  networks = {
    lan = rec {
      wlan = {
        inherit (privateCfg.networks.lan.wlan) ssid;
      };

      config = {
        networkmanager = {
          wlan =
            { uuid }:
            {
              connection = {
                id = "Loc1-Lan-Wlan0";
                inherit uuid;
                type = "wifi";
                autoconnect = false;
              };
              wifi = {
                mode = "infrastructure";
                inherit (wlan) ssid;
              };
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk = "$LOC1_LAN_WLAN0_PSK";
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
        { connectionUuids }:
        {
          ensureProfiles = {
            environmentFiles = [
              "/nix/secrets/network/loc1.env"
            ];
            profiles = rec {
              loc1-lan-wlan = networks.lan.config.networkmanager.wlan {
                uuid = connectionUuids.loc1-lan-wlan;
              };
              loc1-lan-wlan-dhcp_dns = toDhcpDns loc1-lan-wlan {
                uuid = connectionUuids.loc1-lan-wlan-dhcp_dns;
              };
            };
          };
        };
    };
  };
}
