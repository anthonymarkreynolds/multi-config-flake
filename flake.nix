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
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
      };
      lib = nixpkgs.lib;
      myNvim = self.packages.${system}.neovim-custom;
      nvimPath = ./src/programs/neovim-custom;
      pluginList = import "${nvimPath}/plugins-list.nix";
      buildVimPlugin = { name, url, sha256 }: pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = name;
        version = "latest";
        src = builtins.fetchTarball {
          inherit url sha256;
        };
      };

    in {
      packages.${system} = {
        neovim-custom-config = pkgs.stdenv.mkDerivation {
          name = "neovim-custom-config";
          src = self;
            installPhase = ''
            mkdir -p $out/
            cp -r ${nvimPath}/nvim $out/
            '';
        };

        neovim-custom = pkgs.neovim.override {
          configure = {
            customRC = ''
              let g:custom_config_path = '${self.packages.${system}.neovim-custom-config}/nvim'
              exec 'luafile ' . g:custom_config_path . '/init.lua'
            '';
            packages.myVimPackage = with pkgs.vimPlugins; {
              # add plugins from nixpkgs here
              start = [
                nvim-treesitter.withAllGrammars
              ] ++ (map buildVimPlugin pluginList);
            };
          };
        };

        update-plugins = let
          pythonEnv = pkgs.python3.withPackages (ps: [
              ps.requests
          ]);
        in pkgs.writeScriptBin "update-plugins" ''
          #!${pkgs.runtimeShell}
          ${pythonEnv}/bin/python ${nvimPath}/generate-plugins-list.py
        '';
      };

      nixosConfigurations = {
        laptop1 = nixpkgs.lib.nixosSystem {
          inherit system;
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
          extraSpecialArgs = {
            myNvim = myNvim;
          };
        };
      };
    };
}
