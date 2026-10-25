{ private, local-lib, ... }:
let
  inherit (private.hosts.nixos-sbc0.ddns) hostName;

  system = "armv7l-linux";
in
{
  inherit system;

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

  shells = {
    kernelConfigEnv =
      { nixpkgs, localSystem }:
      (import nixpkgs {
        inherit localSystem;
        crossSystem = system;
      }).linuxPackages.kernel.configEnv.overrideAttrs
        (
          finalAttrs: prevAttrs: {
            env.ARCH = "arm";
          }
        );
  };
}
