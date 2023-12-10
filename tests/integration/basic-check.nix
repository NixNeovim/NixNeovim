{ testHelper, haumea, lib }:

# This module performs a very basic check for all available plugins
# It only confirms that there are no errors on startup, when the respective
# module is enabled. This does not check that the plugins is actually loaded
# or otherwise working as intended

let

  inherit (builtins)
    split
    head;

  inherit (lib)
    mapAttrs
    elem
    stringToCharacters
    filter;

  disabledTests = [
    "nvim-cmp"
    "ghosttext" # NOTE: test does not terminate
  ];

  filterActive = names: filter (name: !(elem name disabledTests)) names;

  ########################

  plugins =
    let
      src = haumea.lib.load {
        src = ../../src;
      };

      pluginsNames = builtins.attrNames src.plugins;
      colorschemesNames = builtins.attrNames src.colorschemes;

      active = filterActive pluginsNames;
      group = letters:
        filter (name: elem (head (stringToCharacters name)) (stringToCharacters letters)) active;

    in {
      colorschemes = filterActive colorschemesNames;
      plugins-group1 = group "abcdefghi";
      plugins-group2 = group "jklmnopqr";
      plugins-group3 = group "stuvwxyz";
    };

  tests = mapAttrs
    (group: set:
      map
        (name:
          let
            type = head (split "-" group);
          in {
            "basic-check-${name}" =
              { ... }: {
                programs.nixneovim.${type} = { ${name} = { enable = true; }; };
                nmt.script = testHelper.moduleTest "";
              };

            "basic-check-${name}-use-plugin-default" =
              { ... }: {
                programs.nixneovim.${type} = { ${name} = { enable = true; }; };
                programs.nixneovim.usePluginDefaults = true;
                nmt.script = testHelper.moduleTest "";
              };
          }
        )
        set
    )
    plugins;

in {
  colorschemes = builtins.foldl' (final: set: final // set) { } tests.colorschemes;
  group1 = builtins.foldl' (final: set: final // set) { } tests.plugins-group1;
  group2 = builtins.foldl' (final: set: final // set) { } tests.plugins-group2;
  group3 = builtins.foldl' (final: set: final // set) { } tests.plugins-group3;
}
