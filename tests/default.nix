{ pkgs, home-manager, nmt, nixneovim, ... }:

let

  inherit (builtins)
    attrNames
    readDir;

  lib = pkgs.lib.extend
    (_: super: {
      inherit (home-manager.lib) hm;

      literalExpression = super.literalExpression or super.literalExample;
      literalDocBook = super.literalDocBook or super.literalExample;
    });

  # base config; applied for all tests
  modules = (import (home-manager.outPath + "/modules/modules.nix") {
    inherit lib pkgs;
    check = false;
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
    (import ../nixneovim.nix {})
  ];

  testHelper = {
    config = {
      start = ''
lua <<EOF

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
--               Extra Config (Lua)             --
--------------------------------------------------

    '';
    end = ''





EOF
    '';
    };
    moduleTest = text:
      ''
      nvimFolder="home-files/.config/nvim"
      config=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))
      PATH=$PATH:$(_abs home-path/bin)
      mkdir -p "$(realpath .)/cache/nvim"

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

      start_vim

      # Testing some common file types

      echo "# test" > tmp.md
      start_vim tmp.md

      echo "print(\"works\")" > tmp.py
      start_vim tmp.py

      ${text}
      '';
  };

  filesIn = path:
    let content = attrNames (readDir (./. + "/${path}"));
    in map (x: ./. + "/${path}/${x}") content;

  tests = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests =
      let
        modulesTests = filesIn "plugins";
        testList = [
          ./neovim.nix
          ./basic-check.nix
        ] ++ modulesTests;
      in builtins.foldl'
        (a: b: a // (import b { inherit testHelper nixneovim lib; }))
        { }
        testList;
  };

in tests.build
