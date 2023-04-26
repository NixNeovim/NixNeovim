{ pkgs, home-manager, nmt, ... }:

let
  lib = pkgs.lib.extend
    (_: super: {
      inherit (home-manager.lib) hm;

      literalExpression = super.literalExpression or super.literalExample;
      literalDocBook = super.literalDocBook or super.literalExample;
    });

  modules = (import (home-manager.outPath + "/modules/modules.nix") {
    inherit lib pkgs;

    check = false;
    useNixpkgsModule = false;
  }) ++
  [
    {
      # Fix impurities
      xdg.enable = true;
      home.username = "hm-user";
      home.homeDirectory = "/home/hm-user";
      home.stateVersion = lib.mkDefault "18.09";

      # Test docs separately
      manual.manpages.enable = false;

      imports = [ (home-manager.outPath + "/tests/asserts.nix") ];
    }
  ];

  # inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  checkTest = name: test: pkgs.runCommandLocal "nmt-test-${name}" { } ''
    grep -F 'OK' "${test}/result" >$out
  '';
in
lib.mapAttrs checkTest
  (import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests = builtins.foldl' (a: b: a // (import b)) { } [
      ./module.nix
    ];
  }).report

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


