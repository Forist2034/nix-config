{
  suites,
  pkgs,
  parts,
  ...
}:
{
  imports = [
    suites.develop.home

    parts.taskwarrior.home.default
  ];

  develop = {
    cmake = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    coq = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    cpp = {
      enable = true;
      env = {
        gcc.enable = true;
      };
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    haskell = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
      browser.firefox = {
        enable = true;
        profiles.default.enable = true;
      };
    };
    java = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    latex = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    markdown = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    meson = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    nushell = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    ocaml = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    python = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    rust = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
      browser.firefox = {
        enable = true;
        profiles.default.enable = true;
      };
    };
    scala = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    shell = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    toml = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    typst = {
      enable = true;
      editor = {
        vscodium.enable = true;
        nixvim.enable = true;
      };
    };
    verilog = {
      enable = true;
      editor = {
        nixvim.enable = true;
      };
    };
  };

  programs.vscodium.profiles.default = {
    extensions = pkgs.nix4vscode.forOpenVsx [
      # TODO: use later version when upstream fixed
      "marus25.cortex-debug.1.12.1"
      "mcu-debug.debug-tracker-vscode"
      "mcu-debug.memory-view"
      "mcu-debug.rtos-views"
      "mcu-debug.peripheral-viewer"
    ];
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
