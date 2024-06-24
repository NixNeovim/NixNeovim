{
  description = "A neovim configuration system for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nmd = {
      url = "sourcehut:~rycee/nmd?rev=fb9cf8e991487c6923f3c654b8ae51b6f0f205ce";
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

  };

  outputs = { self, nixpkgs, nmd, nmt, nix-flake-tests, flake-utils, haumea, ... }@inputs:
    {
      nixosModules = {
        default = self.nixosModules.homeManager;
        homeManager = import ./nixneovim.nix { homeManager = true; inherit haumea; };
        homeManager-23-11 = import ./nixneovim.nix { homeManager = true; state = 2311; inherit haumea;  };
        homeManager-24-05 = import ./nixneovim.nix { homeManager = true; state = 2405; inherit haumea;  };
        nixos = import ./nixneovim.nix { homeManager = false; inherit haumea; };
        nixos-23-11 = import ./nixneovim.nix { homeManager = false; state = 2311; inherit haumea; };
        nixos-24-05 = import ./nixneovim.nix { homeManager = false; state = 2405; inherit haumea; };
      };

      overlays.default = inputs.nixneovimplugins.overlays.default;

      lib = import ./lib.nix;
    } //
    flake-utils.lib.eachDefaultSystem (system:
      let
        # system = "x86_64-linux";

        pkgs = import nixpkgs { inherit system; overlays = [ inputs.nixneovimplugins.overlays.default ]; };

        lib = pkgs.lib;

      in
      {
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
            ];
            text = ''
              python ./bin/configparser/main.py
            '';
          };
          newplugin = pkgs.writeShellApplication {
            name = "newplugin";
            runtimeInputs = with pkgs; [ ed ];
            text = ''
            name="$1"
            url=$(echo "$2" | sed 's/[\&/]/\\&/g')
            plugin="$3"

            [ -z "$name" ] && exit 1
            [ -z "$url" ] && exit 1
            [ -z "$plugin" ] && exit 1

            plugin_path="src/plugins/$name.nix"
            plugin_test_path="tests/integration/plugins/$name.nix"

            echo Copy template
            cp ./plugin_template_minimal.nix "$plugin_path"

            echo Replace names
            sed -i "s/PLUGIN_NAME/$name/" "$plugin_path"
            sed -i "s/PLUGIN_URL/$url/" "$plugin_path"

            echo Insert plugin
            ed "$plugin_path" <<EOF
            g/add neovim plugin here/p
            a
                $plugin
            .
            w
            q
            EOF

            echo Copy test template
            cp ./test_template.nix "$plugin_test_path"

            echo Replace names
            sed -i "s/NAME/$name/" "$plugin_test_path"

            echo Adding new files to git
            git add "$plugin_path" "$plugin_test_path"
            '';
          };
        };

        checks =
          let
            nmt-tests = import ./tests.nix {
              inherit nmt pkgs lib;
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
              nmt-tests // { lib = lib-checks.basic; };
      });
}
