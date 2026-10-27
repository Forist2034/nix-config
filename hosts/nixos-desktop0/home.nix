{
  suites,
  pkgs,
  parts,
  ...
}:
let
  devCfg = {
    cfglib.develop = {
      cmake.enable = true;
      cpp.enable = true;
      css.enable = true;
      dhall.enable = true;
      haskell.enable = true;
      html.enable = true;
      java.enable = true;
      javascript.enable = true;
      json.enable = true;
      latex.enable = true;
      markdown.enable = true;
      meson.enable = true;
      nushell.enable = true;
      ocaml.enable = true;
      python.enable = true;
      rust.enable = true;
      scala.enable = true;
      shell.enable = true;
      toml.enable = true;
      typst.enable = true;
      typescript.enable = true;
      verilog.enable = true;
    };
  };
in
{
  imports = [
    suites.develop.home

    parts.taskwarrior.home.default
    devCfg
  ];

  cfglib.develop = {
    cpp = {
      enable = true;
      gcc.enable = true;
    };
  };

  cfglib.programs.firefox = devCfg;

  programs.nixvim = {
    imports = [ devCfg ];
  };

  programs.vscodium = {
    profiles.default = { ... }: {
      imports = [ devCfg ];
      extensions = pkgs.nix4vscode.forOpenVsx [
        # TODO: use later version when upstream fixed
        "marus25.cortex-debug.1.12.1"
        "mcu-debug.debug-tracker-vscode"
        "mcu-debug.memory-view"
        "mcu-debug.rtos-views"
        "mcu-debug.peripheral-viewer"
      ];
    };
  };

  home.packages = with pkgs; [
    gnumake

    ninja

    python3Packages.cocotb
    iverilog

    ghidra

    kicad

    freecad
    openscad-unstable

    openocd
    ninja
    gdb
    inetutils

    gimp
    krita
  ];
}
