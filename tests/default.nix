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

  # base config
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

      HOME=$(realpath .) nvim -u $config -c 'qall' --headless

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
        ] ++ modulesTests;
      in builtins.foldl'
        (a: b: a // (import b { inherit testHelper nixneovim; }))
        { }
        testList;
  };

in tests.build

# pkgs.runCommandLocal "tests" { } ''
#   touch ${placeholder "out"}

#   ${lib.forEach tests (t: t.build)}
# ''


  # ().build # ).build # or report

# { nixpkgs , system , nmt }:

# let
#   pkgs = nixpkgs.legacyPackages.${system};

#   modules = [
#     # {
#     #   _file = ./default.nix;
#     #   _module.args = { inherit pkgs; };
#     # }
#     # ./module.nix
#     # ./tool-test.nix
#     # {}
#     {
#       config.home = {};
#     }
#   ];

#   defaultNixFiles =
#     builtins.filter
#       (x: baseNameOf x == "default.nix")
#       (pkgs.lib.filesystem.listFilesRecursive ./tools);

#   nmtInstance = import nmt {
#     inherit pkgs modules;
#     testedAttrPath = [ "home" ];
#     tests = builtins.foldl' (a: b: a // (import b)) { } defaultNixFiles;
#   };
# in

# pkgs.runCommandLocal "tests" { } ''
#   touch ${placeholder "out"}

#   # ${nmtInstance.run.all.shellHook}
# ''


