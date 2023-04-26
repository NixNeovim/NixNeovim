{ pkgs, home-manager, nmt, ... }:

let
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

  luaHelper = {
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
  };


  tests = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests = builtins.foldl' (a: b: a // (import b { inherit luaHelper; })) { } [
      ./neovim.nix
      ./plugins/telescope.nix
      ./plugins/luasnip.nix
      ./plugins/which-key.nix
      ./plugins/no-config-plugins.nix
    ];
  };

in tests.build



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


