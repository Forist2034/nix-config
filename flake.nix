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

    private-config = {
      type = "git";
      url = "file:///etc/nixos/private";
      rev = "e952afa179f8dd68f42ab92a5c4f07e2c324615e";
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
              flake-inputs = (import ./flake-keep.nix) {
                self = ./.;
                lock = builtins.fromJSON (builtins.readFile ./flake.lock);
              };
            in
            { pkgs, ... }@args:
            {
              environment.etc."flake-inputs".source = flake-inputs args;
            };
        in
        {
          nixos-desktop0 = mkConfig hosts.nixos-desktop0 [
            ./hosts/nixos-desktop0/configuration.nix
            flake-keep
          ];
          nixos-laptop0 = mkConfig hosts.nixos-laptop0 [
            ./hosts/nixos-laptop0/configuration.nix
            flake-keep
          ];
        };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
    };
}
