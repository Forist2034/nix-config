{ private, local-lib, ... }:
let
  inherit (private.hosts.nixos-sbc0.ddns) hostName;
in
{
  system = "armv7l-linux";

  ddns = {
    inherit hostName;
  };

  sshConfig = local-lib.ssh.mkHostConfig {
    name = "nixos-sbc0";
    inherit hostName;
    hostKeys = [
      (builtins.readFile ./ssh_host_ed25519_key.pub)
      (builtins.readFile ./ssh_host_rsa_key.pub)
    ];
  };

  userPasswordFile = user: "/mnt/config/etc/user-passwords/${user}";

  hardware = {
    cpu = {
      threads = 4;
    };
  };
}
