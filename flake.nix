{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      # TODO: use 24.05 branch when available
      url = "github:nix-community/nixvim";

      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, impermanence, ... }@inputs:
    let
      libs = (import ./lib) nixpkgs.lib;
      graphical = import ./graphical;
      system = (import ./system) libs;
      home = import ./home;
      user = import ./user;
      modules = (import ./modules) libs;
    in {
      nixosConfigurations = {
        nixos-laptop0 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            inherit graphical system user home modules;
            info = { system = "x86_64-linux"; };
          };
          modules = [
            home-manager.nixosModules.home-manager
            impermanence.nixosModules.impermanence
            ./host/nixos-laptop0
          ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
    };
}
