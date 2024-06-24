{ pkgs, lib, home-manager, nmt, nixneovim, haumea }:

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

  # helper function to build nmt import function
  nmtCheck = mods:
    (import nmt {
      inherit lib pkgs modules;
      testedAttrPath = [ "home" "activationPackage" ];
      tests = mods;
    }).build.all;

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

    # pluginTests = lib.mapAttrs (name: plugin: nmtCheck { "${name}-test" = plugin."${name}-test";}) integrationTests.plugins;

in {

  basic-colorschemes = nmtCheck integrationTests.basic-check.colorschemes;
  # Running all basic checks together requires a lot of memory. Therefore we split them up in groups
  # see basic-check.nix
  basic-group1 = nmtCheck integrationTests.basic-check.group1;
  basic-group2 = nmtCheck integrationTests.basic-check.group2;
  basic-group3 = nmtCheck integrationTests.basic-check.group3;
  colorschemes = nmtCheck (mergeValues integrationTests.colorschemes);
  environments = nmtCheck (mergeValues integrationTests.environments);
  neovim = nmtCheck ({ inherit (integrationTests) neovim neovim-use-plugin-defaults; });
  plugins = nmtCheck (mergeValues integrationTests.plugins);
  # plugins = pluginTests;
}
