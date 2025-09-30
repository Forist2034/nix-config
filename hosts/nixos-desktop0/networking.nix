{
  local-lib,
  lib,
  locations,
  parts,
  info,
  pkgs,
  ...
}:
let
  eth_default = "enp13s0";
  eth_dmz = "${eth_default}.dmz";

  loc0 = locations.loc0.networks;
in
{
  imports = [
    parts.dynv6.system.default
  ];

  persistence.root = {
    update-dynv6.enable = true;
  };

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
      settings = {
        main = {
          no-auto-default = "*";
        };
      };
    }
    (locations.loc0.config.networking.networkmanager.basic {
      hostId = 1;
      connectionUuids = {
        loc0-lan-wlan = "8f51b6a2-8792-42e7-ab61-340c08ee4641";
        loc0-lan-wlan-dhcp_dns = "1d71cacd-f2ac-484b-863e-9e1e03c03e6a";
      };
    })
    (locations.loc0.config.networking.networkmanager.extra {
      hostId = 1;
      ethDevice = eth_default;
      connectionUuids = {
        loc0-lan-ethernet = "83568938-3d37-441c-a459-4b1dc1a3d4ac";
        loc0-lan-ethernet-dhcp_dns = "1dec1a81-c9ba-4c47-a49c-beaea78fe1c4";
        loc0-trusted-vlan = "94d2e868-11c3-4ac2-ae0c-9616f0636e3e";
        loc0-management-vlan = "b53e0ef1-c960-4c42-9cf5-a98cc0eb7e8f";
        loc0-management-ethernet = "a669a827-116c-4f18-91d9-2ca7b6e52807";
      };
    })
    (
      let
        route-table = 32;
        # for use in string template
        route-table_str = builtins.toString route-table;
        dev_priority = "32";
        ip_priority = "33";
      in
      {
        ensureProfiles.profiles = {
          loc0-dmz-vlan = {
            connection = rec {
              id = "Loc0-Dmz-Vlan";
              type = "vlan";
              autoconnect = lib.mkDefault false;
              uuid = "00c83f33-06d6-47d2-9943-3f4cc4b69d55";
              stable-id = uuid;
              interface-name = eth_dmz;
            };
            vlan = {
              inherit (loc0.dmz.vlan) id;
              parent = eth_default;
            };
            ipv4.method = "disabled"; # only ipv6 address can be accessed publicly
            ipv6 = {
              method = "auto";
              addr-gen-mode = "eui64";
              ip6-privacy = 0; # disabled
              ignore-auto-dns = true;
              route-metric = 1024;
              token = "::2";

              inherit route-table;
              routing-rule1 = "oif ${eth_dmz} table ${route-table_str} priority ${dev_priority}";
              routing-rule2 = "iif ${eth_dmz} table ${route-table_str} priority ${dev_priority}";
            };
          };
        };
        dispatcherScripts = [
          {
            type = "basic";
            source = pkgs.replaceVars ./dmz-rules.nu {
              nushell = "${pkgs.nushell}/bin/nu";

              interface_name = eth_dmz;
              route-table = builtins.toString route-table;
              inherit ip_priority;
            };
          }
        ];
      }
    )
  ];

  services.update-dynv6 = {
    enable = true;
    inherit (info.ddns) hostName;
  };

  specialisation = {
    remote.configuration =
      { config, pkgs, ... }:
      {
        networking.networkmanager = {
          ensureProfiles.profiles = {
            loc0-dmz-vlan = {
              connection.autoconnect = true;
            };
          };
          dispatcherScripts = [
            {
              type = "basic";
              source = pkgs.writeText "update-ddns.sh" ''
                #!${pkgs.bash}/bin/bash

                if [[ $1 != ${eth_dmz} ]] then
                  exit
                fi
                if [[ $2 != "up" && $2 != "dhcp6-change" ]] then
                  exit
                fi
                ${pkgs.systemd}/bin/systemctl restart update-dynv6@${eth_dmz}.service
              '';
            }
          ];
        };
      };
  };
}
