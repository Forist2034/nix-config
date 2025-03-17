{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    local_cdn = {
      # github:owner url is not work
      url = "git+https://github.com/Forist2034/local_cdn?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
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
      parts = import (./parts) libs;
      services = (import ./services) libs;
      suites = (import ./suites) libs;
      graphical = import ./graphical;
      system = (import ./system) libs;
      home = import ./home;
      user = import ./user;
      modules = (import ./modules) libs;
    in
    {
      nixosConfigurations = {
        nixos-laptop0 =
          let
            info = {
              system = "x86_64-linux";
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit (info) system;
            specialArgs = {
              inherit inputs;
              inherit
                graphical
                system
                user
                home
                modules
                info
                parts
                suites
                ;
            };
            modules = [
              home-manager.nixosModules.home-manager
              impermanence.nixosModules.impermanence
              ./host/nixos-laptop0/configuration.nix
            ];
          };
        nixos-desktop0 =
          let
            info = {
              system = "x86_64-linux";
            };
          in
          nixpkgs.lib.nixosSystem {
            inherit (info) system;
            specialArgs = {
              inherit inputs;
              inherit
                graphical
                system
                user
                home
                modules
                info
                parts
                services
                suites
                ;
            };
            modules = [
              home-manager.nixosModules.home-manager
              impermanence.nixosModules.impermanence
              ./host/nixos-desktop0/configuration.nix
            ];
          };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
