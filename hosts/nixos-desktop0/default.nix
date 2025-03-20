{ ssh, ... }:
{
  system = "x86_64-linux";
  sshConfig = ssh.mkHostConfig {
    name = "nixos-desktop0";
    hostKeys = [
      (builtins.readFile ./ssh_host_ed25519_key.pub)
      (builtins.readFile ./ssh_host_rsa_key.pub)
    ];
  };

  userPasswordFile = user: "/nix/secrets/passwords/${user}";

  hardware = {
    cpu = {
      threads = 32;
    };
  };

  home = {
    develop.configuration = import ./home.nix;
  };
}
