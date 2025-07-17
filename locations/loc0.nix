{ private, ... }:
let
  privateCfg = private.locations.loc0;
in
{
  networks = {
    lan = {
      vlan.id = 1024 + 64;
      wlan = {
        inherit (privateCfg.networks.lan.wlan) ssid;
      };
    };
    trusted = {
      vlan.id = 1024 + 16;
    };
    management = {
      vlan.id = 1024;
    };
  };
}
