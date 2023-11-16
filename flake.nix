{
  description = "A neovim configuration system for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nmd = {
      url = "sourcehut:~rycee/nmd";
      flake = false;
    };
    nmt = {
      url = "github:jooooscha/nmt"; # slightly modified version of rycee/nmt
      flake = false;
    };

    nixneovimplugins.url = "github:nixneovim/nixneovimplugins";
    nixneovimplugins.inputs.nixpkgs.follows = "nixpkgs";
    nixneovimplugins.inputs.flake-utils.follows = "flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flake-tests.url = "github:antifuchs/nix-flake-tests";

    flake-utils.url = "github:numtide/flake-utils";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, nmd, nmt, nix-flake-tests, flake-utils, haumea, ... }@inputs:
    {
      nixosModules = {
        default = self.nixosModules.homeManager;
        homeManager = import ./nixneovim.nix { homeManager = true; inherit haumea; };
        homeManager-22-11 = import ./nixneovim.nix { homeManager = true; state = 2211; inherit haumea;  };
        homeManager-23-05 = import ./nixneovim.nix { homeManager = true; state = 2305; inherit haumea;  };
        nixos = import ./nixneovim.nix { homeManager = false; inherit haumea; };
        nixos-22-11 = import ./nixneovim.nix { homeManager = false; state = 2211; inherit haumea; };
        nixos-23-05 = import ./nixneovim.nix { homeManager = false; state = 2305; inherit haumea; };
      };

      overlays.default = inputs.nixneovimplugins.overlays.default;

      lib = import ./lib.nix;
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; overlays = [ inputs.nixneovimplugins.overlays.default ]; };

        lib = pkgs.lib;

      in {

        packages = {
          docs = import ./docs {
            inherit pkgs;
            lib = nixpkgs.lib;
            nmd = import nmd { inherit pkgs lib; };
            inherit haumea;
          };
          configparser = pkgs.writeShellApplication {
            name = "configparser";
            runtimeInputs = let
              python-with-my-packages = pkgs.python3.withPackages (p: with p; [
                tree-sitter
                requests
                mistune
                beautifulsoup4
                coloredlogs
                (
                  buildPythonPackage rec {
                    pname = "SLPP";
                    version = "1.2.3";
                    src = fetchPypi {
                      inherit pname version;
                      sha256 = "sha256-If3ZMoNICQxxpdMnc+juaKq4rX7MMi9eDMAQEUy1Scg=";
                    };
                    doCheck = false;
                    propagatedBuildInputs = [
                      six
                    ];
                  }
                )
              ]);
            in [
              python-with-my-packages
              pkgs.gcc
              pkgs.nixfmt
            ];
            text = ''

              # move to configparser dir
              cd "$(git rev-parse --show-toplevel)/bin/configparser"

              python ./main.py "$@"
            '';
          };
        };

        devShells.configparser = pkgs.mkShell {
          buildInputs = [
            pkgs.python3
            pkgs.poetry
          ];
        };

        checks =
          let
            nmt-tests = import ./tests.nix {
              inherit nmt pkgs;
              nixneovim = self.nixosModules.homeManager;
              inherit (inputs) home-manager;
              inherit haumea;
            };

            lib-checks.basic = nix-flake-tests.lib.check {
              inherit pkgs;
              tests = import ./tests/function-tests.nix { inherit pkgs lib haumea; };
            };
          in
            lib.trace
              "Evaluating for ${system}"
              lib.recursiveUpdate nmt-tests lib-checks;

      });
}
