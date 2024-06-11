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
    let
      # WARN: remove after 24.11 or sometime in future
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.lib.recursiveUpdate {

      # WARN: remove after 24.11 or sometime in future
      nixosModules =
          let
            f = throw "Breaking Change: Please specify your system like this: 'nixneovim.nixosModules.\${system}.default'";
          in {
            default = f;
            homeManager = f;
            homeManager-22-11 = f;
            homeManager-23-05 = f;
            homeManager-23-11 = f;
            nixos = f;
            nixos-22-11 = f;
            nixos-23-05 = f;
            nixos-23-11 = f;
          };

      # WARN: remove after 24.11 or sometime in future
      overlays.default =
        throw "Breaking Change: The NixNeovim overlay is now applied internally. Please remove it from your config";

      lib = import ./lib.nix;

    }
    (flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs { inherit system; overlays = [ inputs.nixneovimplugins.overlays.default ]; };

        lib = pkgs.lib;

        withHomemanager = { homeManager = true; inherit haumea pkgs; };
        withoutHomemanager = { homeManager = false; inherit haumea pkgs; };

      in {

        nixosModules = {
          default = import ./nixneovim.nix withHomemanager;
          homeManager = import ./nixneovim.nix withHomemanager;
          homeManager-23-11 = import ./nixneovim.nix ({ state = 2311; } // withHomemanager);
          homeManager-24-05 = import ./nixneovim.nix ({ state = 2404; } // withHomemanager);
          nixos = import ./nixneovim.nix withoutHomemanager;
          nixos-23-11 = import ./nixneovim.nix ({ state = 2311; } // withoutHomemanager);
          nixos-24-05 = import ./nixneovim.nix ({ state = 2405; } // withoutHomemanager);
        };

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
              {
                lib = lib-checks.basic;
                basic-colorschemes = nmt-tests.basic-colorschemes;
                basic-group1 = nmt-tests.basic-group1;
                basic-group2 = nmt-tests.basic-group2;
                basic-group3 = nmt-tests.basic-group3;
                plugins = nmt-tests.plugins;
                colorschemes = nmt-tests.colorschemes;
                environments = nmt-tests.environments;
                neovim = nmt-tests.neovim;
              };

      }));
}
