{ private, ... }:
let
  privateCfg = private.locations.loc1;
in
{
  networks = {
    lan = {
      wlan = {
        inherit (privateCfg.networks.lan.wlan) ssid;
      };
    };
  };
}
