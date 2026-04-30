{ ... }:
{
  system =
    let
      hosts = {
        codeberg =
          { ... }:
          {
            programs.ssh.extraConfig = ''
              Host codeberg.org
                Protocol 2
                StrictHostKeyChecking yes
                PubkeyAuthentication yes
                PreferredAuthentications publickey

                ForwardAgent no
                ForwardX11 no
                PermitLocalCommand no
                UseRoaming no

                GlobalKnownHostsFile ${./codeberg.keys}
            '';
          };
      };
    in
    {
      inherit hosts;

      default =
        { ... }:
        {
          imports = [ hosts.codeberg ];
        };
    };
}
