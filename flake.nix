{
  description = "A neovim configuration system for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.nmdSrc.url = "gitlab:rycee/nmd";
  inputs.nmdSrc.flake = false;

  outputs = { self, nixpkgs, nmdSrc, vimExtraPlugins, ... }@inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        vimExtraPlugins.overlays.default
      ];
    };

  in {
    packages.${system}.docs = import ./docs {
      pkgs = pkgs;
      lib = nixpkgs.lib;
    };

    nixosModules.nixvim = import ./nixvim.nix { nixos = true; inherit pkgs; };
    homeManagerModules.nixvim = import ./nixvim.nix { homeManager = true; inherit pkgs; };

    # nixosModules = rec {
    #   # default = import ./nixvim.nix { nixos = true; inherit pkgs; };
    #   default = import ./nixvim.nix { nixos = false; inherit pkgs; };
    # };

    # overlays.default = super: self: {
    #   nixvim = self.packages.${system}.default;
    # };

    apps.${system} = {
      default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/nvim";
      };
    };

    packages.${system}.default = pkgs.wrapNeovim pkgs.neovim-unwrapped {
      configure = {
        customRC = ''
          set number relativenumber
        '';
      };
    };

  };
}
