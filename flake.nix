{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private-config = {
      type = "git";
      url = "file:///etc/nixos/private";
      rev = "663c8b552cc9486c588f6dfec87019a8f6cf715d";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      impermanence,
      ...
    }@inputs:
    let
      local-lib = (import ./lib) nixpkgs.lib;
      private = inputs.private-config.config {
        inherit local-lib;
        inherit (nixpkgs) lib;
      };
      args = {
        inherit local-lib private;
        inherit (nixpkgs) lib;
      };
      hosts = (import ./hosts) args;
      locations = (import ./locations) args;
      parts = import (./parts) args;
      services = (import ./services) args;
      suites = (import ./suites) args;
      graphical = import ./graphical;
      system = (import ./system) args;
      home = import ./home;
      users = import ./users;
      modules = (import ./modules) args;
    in
    {
      nixosConfigurations =
        let
          mkConfig =
            info: configs:
            nixpkgs.lib.nixosSystem {
              inherit (info) system;
              specialArgs = {
                inherit inputs info;
                inherit
                  hosts
                  locations
                  local-lib
                  parts
                  private
                  services
                  suites
                  users
                  ;
                inherit
                  graphical
                  home
                  modules
                  system
                  ;
              };
              modules = configs;
            };
          flake-keep =
            let
              flake-inputs = (import ./flake-keep.nix) { inherit (inputs) self; };
            in
            { pkgs, ... }@args:
            {
              environment.etc."flake-inputs".source = flake-inputs args;
            };
          nix4vscode =
            { ... }:
            {
              nixpkgs.overlays = [ inputs.nix4vscode.overlays.forVscode ];
            };
        in
        {
          nixos-desktop0 = mkConfig hosts.nixos-desktop0 [
            ./hosts/nixos-desktop0/configuration.nix
            nix4vscode
            flake-keep
          ];
          nixos-laptop0 = mkConfig hosts.nixos-laptop0 [
            ./hosts/nixos-laptop0/configuration.nix
            nix4vscode
            flake-keep
          ];
        };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
