{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  proxy-group = {
    gid = 512;
    name = "local_cdn-proxy";
  };
  proxy-user = {
    uid = 512;
    name = "local_cdn-proxy";
    isSystemUser = true;
    group = proxy-group.name;
  };
in
{
  imports = [ inputs.local_cdn.nixosModules.local_cdn-dns ];

  users = {
    users = {
      inherit proxy-user;
    };
    groups = {
      inherit proxy-group;
    };
  };

  networking.hosts."127.0.0.1" = [
    "googletagmanager.com"

  ];

  containers.local-cdn = {
    autoStart = true;
    bindMounts = {
      run = {
        hostPath = "/run/local_cdn";
        mountPoint = "/run/local_cdn";
        isReadOnly = false;
      };
      ca = {
        hostPath = "/var/lib/local_cdn";
        mountPoint = "/var/lib/local_cdn";
        isReadOnly = false;
      };
      proxy-cache = {
        hostPath = "/var/cache/local_cdn/proxy";
        mountPoint = "/var/cache/local_cdn/proxy";
        isReadOnly = false;
      };
    };
    config =
      { config, ... }:
      {
        imports = [ inputs.local_cdn.nixosModules.local_cdn ];

        users = {
          users = {
            inherit proxy-user;
          };
          groups = {
            inherit proxy-group;
          };
        };

        environment.etc."resolv.conf".text = ''
          nameserver 127.0.0.100
        '';

        local_cdn = {
          certgen = {
            enable = true;
            inherit (config.services.nginx) user group;
            configs = {
              static = {
                ca.distinguished_name = {
                  organization_unit_name = "local cdn static ca";
                  common_name = "local cdn static ca";
                };
              };
              proxy = {
                ca.distinguished_name = {
                  organization_unit_name = "local cdn cache proxy ca";
                  common_name = "local cdn cache proxy ca";
                };
              };
            };
          };
          googleapis.ajax.enable = true;
          google.enable = true;
          status = {
            enable = true;
            certgen = [
              "static"
              "proxy"
            ];
          };
          proxy = {
            enable = true;
            user = proxy-user.name;
            group = proxy-group.name;
            servers = {
              "cdn.sstatic.net" = { };
              "github.githubassets.com" = { };
            };
          };
        };

        services.nginx = {
          enable = true;
          defaultListenAddresses = [
            "0.0.0.0"
            "unix:/run/local_cdn/nginx/nginx.sock"
          ];
          recommendedTlsSettings = true;
          virtualHosts.local_cdn-status = {
            serverName = "static.local-cdn.internal";
            default = true;
          };
        };

        systemd.services.nginx =
          let
            depends = [
              "local_cdn-certgen@static.service"
              "local_cdn-certgen@proxy.service"
            ];
          in
          {
            serviceConfig.RuntimeDirectory = lib.mkForce "nginx local_cdn/nginx";
            wants = depends;
            after = depends;
          };

        system.stateVersion = "23.11";
      };
  };

  systemd.services."container@local-cdn".serviceConfig = {
    RuntimeDirectory = [ "local_cdn" ];
    StateDirectory = [ "local_cdn" ];
    CacheDirectory = [ "local_cdn/proxy" ];
  };

  local_cdn.dns = {
    enable = true;
    config = {
      upstream =
        let
          aliyun_ips = [
            "223.5.5.5"
            "223.6.6.6"
            "[2400:3200::1]"
            "[2400:3200:baba::1]"
          ];
        in
        {
          cloudflare.config = "cloudflare";
          cloudflare_https.config = "cloudflare_https";
          aliyun.config.custom = {
            name_servers = builtins.concatMap (ip: [
              {
                socket_addr = "${ip}:53";
                protocol = "udp";
              }
              {
                socket_addr = "${ip}:53";
                protocol = "tcp";
              }
            ]) aliyun_ips;
          };
          aliyun_https.config.custom = {
            name_servers = builtins.map (ip: {
              socket_addr = "${ip}:443";
              tls_dns_name = "dns.alidns.com";
              protocol = "https";
            }) aliyun_ips;
          };
        };
      servers =
        let
          cloudflare = [
            "cloudflare_https"
            "cloudflare"
          ];
          aliyun = [
            "aliyun_https"
            "aliyun"
          ];

          cacheProxy = domain: upstream: {
            domains = [ "${domain}." ];
            action.unix_srv_or_forward = {
              path = "/run/local_cdn/proxy/${domain}/proxy.sock";
              active = {
                ttl = 10;
                data = [ { A = "127.0.0.1"; } ];
              };
              forward = {
                inherit upstream;
              };
            };
          };
        in
        {
          main = {
            action = {
              default_action.forward = {
                upstream = [
                  "cloudflare_https"
                  "cloudflare"
                ];
              };
              actions = [
                {
                  domains = [
                    "ajax.googleapis.com."
                    "fonts.googleapis.com."
                    "www.google.com."
                  ];
                  action.unix_srv_or_block = {
                    path = "/run/local_cdn/nginx";
                    active = {
                      ttl = 10;
                      data = [ { A = "127.0.0.1"; } ];
                    };
                    inactive = {
                      ttl = 10;
                    };
                  };
                }
                (cacheProxy "github.githubassets.com" cloudflare)
                (cacheProxy "cdn.sstatic.net" cloudflare)
                {
                  domains = [
                    "recaptcha.net."
                    "google.cn."
                    "googleapis.cn."
                    "gstatic.cn."
                    "cdn.jsdelivr.net."
                    "cdnjs.cloudflare.com."
                  ];
                  action.forward = {
                    upstream = aliyun;
                  };
                }
              ];
            };
            listen = [
              { udp = "127.0.0.1:53"; }
              {
                tcp = {
                  address = "127.0.0.1:53";
                  timeout_sec = 10;
                };
              }
            ];
          };
          cf_forward = {
            action = {
              default_action.forward = {
                upstream = cloudflare;
              };
              actions = [ ];
            };
            listen = [
              { udp = "127.0.0.100:53"; }
              {
                tcp = {
                  address = "127.0.0.100:53";
                  timeout_sec = 10;
                };
              }
            ];
          };
        };
    };
  };
  systemd.services.local_cdn-dns = {
    wantedBy = [ "multi-user.target" ];
  };
}
