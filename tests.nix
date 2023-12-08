{ pkgs, home-manager, nmt, nixneovim, haumea }:

let

  helpers = haumea.lib.load {
    src = ./helpers;
    # inputs = {
      # inherit lib config;
      # # usePluginDefaults = config.programs.nixneovim.usePluginDefaults;
    # };
    # NOTE: inputs are disabled here, because the functions we use do not need them
  };

  integrationTests = haumea.lib.load {
    src = ./tests/integration;
    inputs = {
      inherit testHelper pkgs haumea lib;
    };
  };

  inherit (helpers.utils)
    testHelper
    mergeValues;

  lib = pkgs.lib.extend
    (_: super: {
      inherit (home-manager.lib) hm;

      literalExpression = super.literalExpression or super.literalExample;
      literalDocBook = super.literalDocBook or super.literalExample;
    });

  # base config; applied for all tests
  modules =
    (import (home-manager.outPath + "/modules/modules.nix") {
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

      # import NixNeovim module
      (import ./nixneovim.nix { inherit haumea; })
    ];

  basicChecks = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests = integrationTests.basic-check;
  };

  plugins = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests = mergeValues integrationTests.plugins;
  };

  colorschemes = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests = mergeValues integrationTests.colorschemes;
  };

  neovim = import nmt {
    inherit lib pkgs modules;
    testedAttrPath = [ "home" "activationPackage" ];
    tests = { inherit (integrationTests) neovim neovim-use-plugin-defaults; };
  };

in {
  basic = basicChecks.build.all;
  plugins = plugins.build.all;
  colorschemes = colorschemes.build.all;
  neovim = neovim.build.all;
}
