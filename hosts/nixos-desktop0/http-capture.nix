{ profile_id, port }:
{
  inputs,
  pkgs,
  config,
  ...
}:
let
  profile = "capture";

  hc-bin = pkgs.rustPlatform.buildRustPackage {
    pname = "http-capture";
    version = "0.1.0";
    src = "${inputs.http-capture}";
    cargoLock.lockFile = "${inputs.http-capture}/Cargo.lock";
  };

  ff-wrapper = pkgs.writeShellApplication {
    name = "hc-firefox";
    runtimeInputs = [
      pkgs.nss.tools
      config.programs.firefox.finalPackage
    ];
    text =
      let
        cert_name = "mitmproxy-capture";
        profile_dir = "${config.home.homeDirectory}/.mozilla/firefox/${profile}";
      in
      ''
        set -o errexit -o xtrace

        readonly cert_file="$HC_MITMPROXY_CONFDIR/mitmproxy-ca.pem"

        certutil -d "${profile_dir}" -A -t C,p,p -n "${cert_name}" -i "$cert_file"
        ln -svf ~/.mozilla/firefox/default/places.sqlite ${profile_dir}/places.sqlite
        ln -svf ~/.mozilla/firefox/default/places.sqlite-shm ${profile_dir}/places.sqlite-shm
        ln -svf ~/.mozilla/firefox/default/places.sqlite-wal ${profile_dir}/places.sqlite-wal
        exec firefox -P "${profile}"
      '';
  };
in
{
  home.packages = [ pkgs.mitmproxy ];

  programs.firefox = {
    profiles.capture =
      let
        def = config.programs.firefox.profiles.default;
      in
      {
        id = profile_id;
        search = {
          inherit (def.search) engines default force;
        };
        settings = def.settings // {
          "network.proxy.socks" = "127.0.0.1";
          "network.proxy.socks_port" = port;
          "network.proxy.socks_version" = 5;
          "network.proxy.socks5_remote_dns" = true;
          "network.proxy.type" = 1;
        };
      };
  };

  xdg.configFile."http-capture/mitmproxy/config.yaml".text = ''
    listen_host: '127.0.0.1'
    listen_port: ${builtins.toString port}
    mode:
      - socks5
  '';

  xdg.desktopEntries.firefox-capture = {
    name = "Firefox (capture)";
    icon = "firefox";
    exec = builtins.concatStringsSep " " [
      "${hc-bin}/bin/hc-capture"
      "--root"
      "${config.home.homeDirectory}/Documents/http-records/mitmdump"
      "--mitm-config-dir"
      "${config.xdg.configHome}/http-capture/mitmproxy"
      "run"
      "${ff-wrapper}/bin/hc-firefox"
    ];
    categories = [
      "Network"
      "WebBrowser"
    ];
    terminal = true;
  };
}
