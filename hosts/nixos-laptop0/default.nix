{ local-lib, ... }:
{
  system = "x86_64-linux";
  sshConfig = local-lib.ssh.mkHostConfig {
    name = "nixos-laptop0";
    hostKeys = [
      (builtins.readFile ./ssh_host_ed25519_key.pub)
      (builtins.readFile ./ssh_host_rsa_key.pub)
    ];
  };

  userPasswordFile = user: "/nix/secrets/passwords/${user}";

  hardware = {
    cpu = {
      threads = 8;
    };
  };

  home = {
    develop.configuration = import ./home.nix;
  };
}
