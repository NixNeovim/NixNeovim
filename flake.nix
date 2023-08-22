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
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nmd, nmt, nix-flake-tests, flake-utils, haumea, ... }@inputs:
    {
      nixosModules = {
        default = import ./nixneovim.nix { homeManager = true; };
        homeManager = self.nixosModules.default;
        homeManager-22-11 = import ./nixneovim.nix { homeManager = true; state = 2211; };
        nixos = import ./nixneovim.nix { homeManager = false; };
        nixos-22-11 = import ./nixneovim.nix { homeManager = false; state = 2211; };
        haumea = { config, lib, ... }:
          let
            cfg = config.programs.nixneovim;

            system = "x86_64-linux";
            pkgs = import nixpkgs { inherit system; overlays = [ inputs.nixneovimplugins.overlays.default ]; };

            helpers = haumea.lib.load {
              src = ./helpers;
              inputs = {
                # usePluginDefaults = config.programs.nixneovim.usePluginDefaults;
                usePluginDefaults = false;
                inherit (pkgs) lib;
                inherit config;
              };
            };

            plugin-configs = haumea.lib.load {
              src = ./src;
              inputs = {
                homeManager = true;
                state = 2211;
                inherit pkgs;
                inherit (pkgs) lib;
                inherit config;
                inherit helpers;
              };
            };
          in {

            options.programs.nixneovim = {
              enable = lib.mkEnableOption "";
              extraConfigLua = lib.mkOption {
                type = lib.types.lines;
                default = "";
                description = "Extra contents for init.lua";
              };

              # combine all options from all plugins
              plugins =
                lib.mapAttrs
                  (k: v: v.options)
                  plugin-configs;
            };

            # config.programs.nixneovim.extraConfigLua = lib.mkIf true "test";

            # combine all configs from all plugins
            config.programs.nixneovim = {
              extraConfigLua = "hi";
                # let

                  # # get config declaration from each plugin
                  # configs = lib.mapAttrs
                    # (k: v: v.config)
                    # plugin-configs;
                  
                  # # # combined = lib.mapAttrs lib.recursiveUpdate configs;
                  # # combined = lib.mapAttrsToList
                    # # (k: v: v)
                    # # configs;

                 # # in lib.concatStringsSep "\n" configs;
                 # in configs;
            };

            config.programs.neovim = {
                enable = true;
                extraLuaConfig =
                  let
                    config = config.programs.nixneovim;
                  in ''
                    ${lib.concatStringsSep "\n" config}
                  '';
                  # let
                    # config = lib.mapAttrsToList
                      # (k: v: lib.trace v.config v.config.content)
                      # plugin-configs;
                  # in ''
                    # ${lib.concatStringsSep "\n" config}
                  # '';
              };
          };
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

            plugin_path="plugins/utils/$name.nix"
            plugin_test_path="tests/plugins/$name.nix"

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
            nmt-tests = import ./tests {
              inherit nmt pkgs;
              nixneovim = self.nixosModules.homeManager;
              inherit (inputs) home-manager;
            };

            lib-checks.basic = nix-flake-tests.lib.check {
              inherit pkgs;
              tests = pkgs.callPackage ./tests.nix {};
            };
          in lib.recursiveUpdate nmt-tests lib-checks;

         # devShells = forAllSystems (system:
         #  let
         #    pkgs = nixpkgs.legacyPackages.x86_64-linux;
         #    tests = import ./tests { inherit lib pkgs nmt; };
         #  in {
         #    default = tests.run;
         #  });

        # devShells.x86_64-linux.default = import nmt {
        #     inherit lib pkgs modules;
        #     testedAttrPath = [ "home" "activationPackage" ];
        #     tests = {
        #       testa = {
        #       config = {
        #         programs.neovim = {
        #           enable = true;
        #           extraConfig = ''
        #             let g:hmExtraConfig='HM_EXTRA_CONFIG'
        #               '';
        #               plugins = with pkgs.vimPlugins; [
        #                 vim-nix
        #                 {
        #                   plugin = vim-commentary;
        #                   config = ''
        #                     let g:hmPlugins='HM_PLUGINS_CONFIG'
        #                   '';
        #                 }
        #               ];
        #               extraLuaPackages = [ pkgs.lua51Packages.luautf8 ];
        #             };

        #             nmt.script = ''
        #               vimout=$(mktemp)
        #               echo "redir >> /dev/stdout | echo g:hmExtraConfig | echo g:hmPlugins | redir END" \
        #                 | ${pkgs.neovim}/bin/nvim -es -u "$TESTED/home-files/.config/nvim/init.lua" \
        #                 > "$vimout"
        #               assertFileContains "$vimout" "HM_EXTRA_CONFIG"
        #               assertFileContains "$vimout" "HM_PLUGINS_CONFIG"
        #             '';
        #           };
        #       };
        #     };
        #   };

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

      });
}
