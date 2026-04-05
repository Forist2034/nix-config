{
  pkgs,
  suites,
  parts,
  ...
}:
{
  imports = [
    suites.develop.home

    parts.taskwarrior.home.default
  ];

  home.packages = with pkgs; [
    wireshark

    rtl-sdr
    sdrpp
    dump1090-fa
    (gnuradio.override { extraPackages = with gnuradioPackages; [ osmosdr ]; })
  ];
}
