{ ... }:
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
      profiles = {
        loc0-lan-ethernet = {
          connection = {
            id = "Loc0-Lan-Ethernet";
            type = "ethernet";
            interface-name = "enp13s0";
            uuid = "83568938-3d37-441c-a459-4b1dc1a3d4ac";
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.8.32/24,192.168.8.1";
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
            type = "vlan";
            uuid = "94d2e868-11c3-4ac2-ae0c-9616f0636e3e";
          };
          vlan = {
            id = 64;
            parent = "enp13s0";
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.64.32/24";
          };
          ipv6 = {
            method = "disabled";
          };
        };
        loc0-management-vlan = {
          connection = {
            id = "Loc0-Management-Vlan";
            type = "vlan";
            autoconnect = false;
            uuid = "b53e0ef1-c960-4c42-9cf5-a98cc0eb7e8f";
            permissions = "user:reid:";
          };
          vlan = {
            id = 128;
            parent = "enp13s0";
          };
          ipv4 = {
            method = "manual";
            address1 = "192.168.128.32/24";
            may-fail = false;
          };
          ipv6 = {
            method = "disabled";
          };
        };
      };
    };
  };
}
