{
  description = "A neovim configuration system for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nmd = {
      url = "gitlab:rycee/nmd";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nmd, ... }@inputs:
    let
      system = "x86_64-linux";

      # pkgs = import nixpkgs { inherit system; };

    in {
      # packages.${system}.docs = import ./docs {
      #   pkgs = pkgs;
      #   lib = nixpkgs.lib;
      # };

      nixosModules = rec {
        default = import ./nixvim.nix { homeManager = true; };
        homeManager = self.nixosModules.default;
        nixos = import ./nixvim.nix { homeManager = false; };
      };

      # overlays.default = super: self: {
      #   nixvim = self.packages.${system}.default;
      # };

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
