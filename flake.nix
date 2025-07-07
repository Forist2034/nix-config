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
      # url = "github:nix-community/nixvim/nixos-25.05";
      # TODO: use latest after https://github.com/nix-community/nixvim/issues/3532 were fixed
      url = "github:nix-community/nixvim/cfea16cdbe4f13b5d39dfe3df747092448252c9d";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    private-config = {
      type = "git";
      url = "file:///etc/nixos/private";
      rev = "20bfe81e328ee5c7e60e203ce8ab5ed4d85abdb6";
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
      libs = (import ./lib) nixpkgs.lib;
      hosts = (import ./hosts) libs;
      parts = import (./parts) libs;
      private = inputs.private-config.config libs;
      services = (import ./services) libs;
      suites = (import ./suites) libs;
      graphical = import ./graphical;
      system = (import ./system) libs;
      home = import ./home;
      users = import ./users;
      modules = (import ./modules) libs;
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
                  parts
                  private
                  services
                  suites
                  users
                  ;
                local-lib = libs;
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
