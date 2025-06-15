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
  ];
}
