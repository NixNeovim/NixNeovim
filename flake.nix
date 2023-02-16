{
  description = "A neovim configuration system for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nmd = {
      url = "gitlab:rycee/nmd";
      flake = false;
    };

    nixneovimplugins.url = "github:nixneovim/nixneovimplugins";
    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";
  };

  outputs = { self, nixpkgs, nmd, nix-flake-tests, ... }@inputs:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; overlays = [ inputs.nixneovimplugins.overlays.default ]; };

      lib = pkgs.lib;

    in
    {
      packages.${system}.docs = import ./docs {
        inherit pkgs;
        lib = nixpkgs.lib;
        nmd = import nmd { inherit pkgs lib; };
      };

      nixosModules = rec {
        default = import ./nixneovim.nix { homeManager = true; };
        homeManager = self.nixosModules.default;
        nixos = import ./nixneovim.nix { homeManager = false; };
      };

      overlays.default = inputs.nixneovimplugins.overlays.default;

      lib = import ./lib.nix;

      checks.x86_64-linux = {
        basic =
          nix-flake-tests.lib.check {
            inherit pkgs;
            tests = pkgs.callPackage ./tests.nix {};
          };
      };

      # apps.${system} = {
      #   default = {
      #     type = "app";
      #     program = "${self.packages.${system}.default}/bin/nvim";
      #   };
      # };

      # packages.${system}.default = pkgs.wrapNeovim pkgs.neovim-unwrapped {
      #   configure = {
      #     customRC = ''
      #       set number relativenumber
      #     '';
      #   };
      # };

    };
}
