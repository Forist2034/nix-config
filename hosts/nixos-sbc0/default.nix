{ local-lib, ... }:
{
  system = "armv7l-linux";

  sshConfig = local-lib.ssh.mkHostConfig {
    name = "nixos-sbc0";
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
