{ private, local-lib, ... }:

let
  inherit (private.hosts.nixos-desktop0.ddns) hostName;
in
{
  system = "x86_64-linux";

  ddns = {
    inherit hostName;
  };

  sshConfig = local-lib.ssh.mkHostConfig {
    name = "nixos-desktop0";
    inherit hostName;
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
