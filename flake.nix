{
  description = "A neovim configuration system for NixOS";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.nmdSrc.url = "gitlab:rycee/nmd";
  inputs.nmdSrc.flake = false;

  inputs.vimExtraPlugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";

  outputs = { self, nixpkgs, nmdSrc, vimExtraPlugins, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            vimExtraPlugins.overlays.default
          ];
        };

        opt = [
          ./options/nixvim.nix
        ];

      in {

        packages.docs = import ./docs {
          inherit nmdSrc pkgs;
          lib = nixpkgs.lib;
        };

        # nixosModules.nixvim = import ./wrappers/nixos.nix {}; # TODO
        # homeManagerModules.nixvim = import ./modules/home-manager.nix ;
        # nixosModules.nixvim = import ./nixvim.nix { nixos = true; inherit pkgs; };
        # homeManagerModules.nixvim = import ./nixvim.nix { homeManager = true; inherit pkgs; };
        # legacyPackages.makeNixvim = import ./modules/standalone.nix; # TODO
      }

  ) // {
    homeManagerModule = import ./modules/home-manager.nix;
  };
}
