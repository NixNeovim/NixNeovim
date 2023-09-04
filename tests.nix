{ pkgs, home-manager, nmt, nixneovim, haumea, ... }:

let

  lib = pkgs.lib.extend
    (_: super: {
      inherit (home-manager.lib) hm;

      literalExpression = super.literalExpression or super.literalExample;
      literalDocBook = super.literalDocBook or super.literalExample;
    });

  # base config; applied for all tests
  modules = (import (home-manager.outPath + "/modules/modules.nix") {
    inherit lib pkgs;
    check = true;
    useNixpkgsModule = false;
  }) ++
  [
    {
      # Fix impurities
      xdg.enable = true;
      home = {
        username = "hm-user";
        homeDirectory = "/home/hm-user";
        stateVersion = lib.mkDefault "22.11";
      };

      programs.nixneovim = {
        enable = true;
      };

      # Test docs separately
      manual.manpages.enable = false;
    }

    # improt NixNeovim module
    (import ./nixneovim.nix { inherit haumea; })
  ];

  testHelper = {
    config = {
      start = ''
--------------------------------------------------
--                 Globals                      --
--------------------------------------------------


--------------------------------------------------
--                 Options                      --
--------------------------------------------------


--------------------------------------------------
--                 Keymappings                  --
--------------------------------------------------



--------------------------------------------------
--                 Augroups                     --
--------------------------------------------------



--------------------------------------------------
--               Extra Config (Lua)             --
--------------------------------------------------

    '';
    end = "";
    };
    moduleTest = text:
      ''
      echo Begin test
      nvimFolder="home-files/.config/nvim"
      config="$(_abs $nvimFolder/init.lua)"
      assertFileExists "$config"

      PATH=$PATH:$(_abs home-path/bin)
      mkdir -p "$(realpath .)/cache/nvim" # add cache dir; needed for barbar.json
      HOME=$(realpath .) nvim -u "$config" -c 'qall' --headless
      echo # add missing \0 to output of 'nvim'

      # Replace the path the vimscript file, because it contains the hash
      sed "s/\/nix\/store\/[a-z0-9]\{32\}/\<nix-store-hash\>/" "$config" > normalizedConfig.lua
      normalizedConfig=normalizedConfig.lua

      neovim_error() {
        echo ----------------- NEOVIM CONFIG -----------------
        cat -n "$config"
        echo -------------------------------------------------

        echo
        echo

        echo ----------------- NEOVIM INFO -------------------
        nvim --version
        echo -------------------------------------------------

        echo ----------------- NEOVIM PATH -------------------
        echo $PATH
        echo -------------------------------------------------

        echo ----------------- NEOVIM OUTPUT -----------------
        echo "$1"
        echo -------------------------------------------------
        exit 1
      }

      start_vim () {
        OUTPUT=$(HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) nvim -u $config --headless "$@" -c 'qall' 2>&1)
        if [ "$OUTPUT" != "" ]
        then
          neovim_error "$OUTPUT"
        fi
      }

      check_colorscheme () {
        OUTPUT=$(HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) nvim -u $config --headless -c 'colorscheme' -c 'qall' 2>&1)
        if [ "$OUTPUT" != "$1" ]
        then
          neovim_error "Expected '$1'. Found: '$OUTPUT'"
        fi
      }

      echo Start Vim tests
      start_vim

      echo Testing some common file types

      echo "# test" > tmp.md
      start_vim tmp.md

      echo "print(\"works\")" > tmp.py
      start_vim tmp.py

      cat << EOF > tmp.rs
        fn main() {
          println!("Hello, world!");
        }
      EOF
      start_vim tmp.rs

      echo Vim tests done

      ${text}
      '';
  };

  tests = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests =
      let
        integrationTests = haumea.lib.load {
          src = ./tests/integration;
          inputs = {
            inherit testHelper pkgs haumea lib;
          };
        };

      in  with integrationTests; {
          inherit (integrationTests)
            neovim
            neovim-use-plugin-defaults;
        } //
        basic-check //
        plugins.bamboo //
        # src.cmp // # NOTE: runs forever
        plugins.hbac //
        plugins.incline //
        plugins.lspconfig //
        plugins.lspsaga //
        plugins.lualine //
        plugins.luasnip //
        plugins.markdown-preview //
        plugins.no-config-plugins //
        plugins.oil //
        plugins.plantuml-syntax //
        plugins.rust //
        plugins.telescope //
        plugins.treesitter //
        plugins.which-key //
        plugins.zk;
  };

in tests.build
