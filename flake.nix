{
  description = "multi-config-flake: A Nix flake for managing configurations across multiple NixOS machines and Home Manager users";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      unstable = import nixpkgs-unstable {
        inherit system;
      };
      lib = nixpkgs.lib;

    in {
      nixosConfigurations = {
        laptop1 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit unstable; };
          modules = [
            ./src/machines/laptop1/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        anthony = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./src/users/anthony/home.nix ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { };
        };
      };
    };
}
