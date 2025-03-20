{ ... }:
let
  mkConfig =
    cpuCount:
    let
      cpu =
        if cpuCount <= 16 then
          {
            left = "LeftCPUs";
            right = "RightCPUs";
          }
        else
          {
            left = "LeftCPUs2";
            right = "RightCPUs2";
          };
    in
    ''
      ${builtins.readFile ./htoprc}
      header_layout=two_50_50
      column_meters_0=${cpu.left} PressureStallCPUSome Memory Zram HugePages Swap PressureStallMemorySome PressureStallMemoryFull DiskIO NetworkIO
      column_meter_modes_0=1 2 1 1 1 1 2 2 2 2
      column_meters_1=${cpu.right} Uptime Systemd SystemdUser Tasks Battery LoadAverage PressureStallIRQFull PressureStallIOSome PressureStallIOFull
      column_meter_modes_1=1 2 2 2 2 1 2 2 2 2
      screen:Main=PID USER PRIORITY NICE M_VIRT M_RESIDENT M_SHARE STATE PERCENT_CPU PERCENT_MEM TIME Command
      .tree_view=1
      screen:I/O=PID USER IO_PRIORITY IO_RATE IO_READ_RATE IO_WRITE_RATE PERCENT_SWAP_DELAY PERCENT_IO_DELAY Command
      .tree_view=1
    '';
in
{
  system = {
    default =
      { info, pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.htop ];
        environment.etc."htoprc".text = mkConfig info.hardware.cpu.threads;
      };
  };
}
