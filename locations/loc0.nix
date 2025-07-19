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
    dmz = {
      vlan.id = 1024 + 32;
    };
    management = {
      vlan.id = 1024;
    };
  };
}
