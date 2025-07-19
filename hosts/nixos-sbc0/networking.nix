{
  locations,
  parts,
  pkgs,
  info,
  ...
}:
{

  imports = [
    parts.dynv6.system.default
  ];

  networking.useNetworkd = true;

  services.resolved = {
    enable = true;
    extraConfig = ''
      [Resolve]
      DNS=${
        builtins.concatStringsSep " " [
          "1.0.0.1"
          "1.1.1.1"
          # aliyun dns
          "223.5.5.5"
          "223.6.6.6"
        ]
      }
      Domains=~.
    '';
  };

  systemd.network = {
    enable = true;
    networks = {
      # disable duplicate interface, otherwise can't connect to network
      "10-disable-wlan1" = {
        name = "wlan1";
        matchConfig = {
          Type = "wlan";
          WLANInterfaceType = "station";
        };
        linkConfig.ActivationPolicy = "always-down";
      };

      "20-loc0-lan-wlan" = {
        matchConfig = {
          Type = "wlan";
          WLANInterfaceType = "station";
          SSID = locations.loc0.networks.lan.wlan.ssid;
        };

        linkConfig = {
          RequiredForOnline = "routable";
        };
        networkConfig = {
          IgnoreCarrierLoss = "3s";
        };

        DHCP = "ipv6";
        addresses = [
          { Address = "10.64.3.1/16"; }
        ];
        gateway = [ "10.64.0.1" ];
        dhcpV6Config = {
          UseDNS = false;
        };
      };

      "21-loc1-lan-wlan0" = {
        matchConfig = {
          Type = "wlan";
          WLANInterfaceType = "station";
          SSID = locations.loc1.networks.lan.wlan.ssid;
        };

        linkConfig = {
          RequiredForOnline = "routable";
        };
        networkConfig = {
          IgnoreCarrierLoss = "3s";
        };

        DHCP = "yes";
        dhcpV4Config = {
          UseDNS = false;
        };
        dhcpV6Config = {
          UseDNS = false;
        };
      };
    };
  };

  networking.wireless.iwd = {
    enable = true;
  };

  services.update-dynv6 = {
    enable = true;
    inherit (info.ddns) hostName;
  };
  persistence.config = {
    update-dynv6 = {
      enable = true;
    };
  };

  systemd.timers."update-dynv6@wlan0" = {
    timerConfig = {
      OnBootSec = 30;
      OnUnitActiveSec = 60 * 5;
    };

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    wantedBy = [ "timers.target" ];
  };
}
