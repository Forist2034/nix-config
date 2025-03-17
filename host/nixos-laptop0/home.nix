{
  pkgs,
  suites,
  home,
  ...
}:
{
  imports = [
    suites.develop.home

    home.taskwarrior
  ];

  home.packages = with pkgs; [
    wireshark

    xsel
    xclip
  ];
}
