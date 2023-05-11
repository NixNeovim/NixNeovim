{ testHelper, ... }:

# This module performs a very basic check for all available plugins
# It only confirms that there are no errors on startup, when the respective
# module is enabled. This does not check that the plugins is actually loaded
# or otherwise working as intended
# Because the evaluation of the neovim derivation would take too long when
# activating all plugins at the same time, we split activate them in groups
# The groups are formed by the starting letter of the plugin name.
# This ways only a couple of plugins are activated at the same time.

let
  letters = [
    "a"
    "b"
    "c"
    "d"
    "e"
    "f"
    "g"
    "h"
    "i"
    "j"
    "k"
    "l"
    "m"
    "n"
    "o"
    "p"
    "q"
    "r"
    "s"
    "t"
    "u"
    "v"
    "w"
    "x"
    "y"
    "z"
  ];

  sets = map
    (letter:
      {
        "basic-check-test-${letter}" = { config, lib, pkgs, ... }:
          {
            config =
              let

                plugins = config.programs.nixneovim.plugins;

                # only activate plugins matched by the first character of their name
                filteredPlugins =
                  lib.filterAttrs
                  (k: v:
                    let
                      firstChar = lib.head (lib.stringToCharacters k);
                    in firstChar == letter)
                    plugins;

                autoPlugins = lib.mapAttrs
                  (k: v: { enable = true; })
                  filteredPlugins;

                # Some plugins are correctly loaded
                # Therefore, we have to load them manually here
                pluginsWithErrors = {
                  nvim-cmp.snippet.enable = true;
                  ghosttext.enable = false; # FIX: does not compile when activated
                };

              in {
                programs.nixneovim.plugins = autoPlugins // pluginsWithErrors;

                nmt.script = testHelper.moduleTest "";
              };
          };
      }
    )
    letters;
in builtins.foldl' (a: b: a // b) {} sets
