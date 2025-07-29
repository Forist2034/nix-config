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

      ensureProfiles = {
        profiles =
          let
            toDhcpDns = local-lib.networkmanager.profile.toDhcpDns;
          in
          rec {
            loc0-lan-ethernet = {
              connection = {
                id = "Loc0-Lan-Ethernet";
                type = "ethernet";
                interface-name = eth_default;
                uuid = "83568938-3d37-441c-a459-4b1dc1a3d4ac";
              };
              ipv4 = {
                method = "manual";
                address1 = "10.64.1.1/16,10.64.0.1";
              };
              ipv6 = {
                method = "auto";
                ignore-auto-dns = true;
              };
            };
            loc0-lan-ethernet-dhcp_dns = toDhcpDns loc0-lan-ethernet {
              uuid = "1dec1a81-c9ba-4c47-a49c-beaea78fe1c4";
              ipv4.dns = "10.64.0.1";
            };
            loc0-trusted-vlan = {
              connection = {
                id = "Loc0-Trusted-Vlan";
                type = "vlan";
                uuid = "94d2e868-11c3-4ac2-ae0c-9616f0636e3e";
                interface-name = "${eth_default}.trust";
              };
              vlan = {
                inherit (loc0.trusted.vlan) id;
                parent = eth_default;
              };
              ipv4 = {
                method = "manual";
                address1 = "10.16.1.1/16";
              };
              ipv6.method = "disabled";
            };

            loc0-management-vlan = {
              connection = {
                id = "Loc0-Management-Vlan";
                type = "vlan";
                autoconnect = false;
                uuid = "b53e0ef1-c960-4c42-9cf5-a98cc0eb7e8f";
                permissions = "user:reid:";
                interface-name = "${eth_default}.mgmt";
              };
              vlan = {
                inherit (loc0.management.vlan) id;
                parent = eth_default;
              };
              ipv4 = {
                method = "manual";
                address1 = "10.0.1.1/16";
                may-fail = false;
              };
              ipv6.method = "disabled";
            };
          };
      };
    }
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
