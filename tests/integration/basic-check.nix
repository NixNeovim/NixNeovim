{ testHelper, haumea, lib }:

# This module performs a very basic check for all available plugins
# It only confirms that there are no errors on startup, when the respective
# module is enabled. This does not check that the plugins is actually loaded
# or otherwise working as intended

let

  inherit (lib)
    mapAttrs
    elem
    filter;

  plugins =
    let
      src = haumea.lib.load {
        src = ../../src;
      };

      pluginsNames = builtins.attrNames src.plugins;
      colorschemesNames = builtins.attrNames src.colorschemes;

    in {
      # inherit (src)
        # plugins
        # colorschemes;
      # src.plugins; # TODO: add the other plugins
      plugins = filterActive pluginsNames;
      colorschemes = filterActive colorschemesNames;
    };

  disabledTests = [
    "nvim-cmp"
    "ghosttext" # NOTE: test does not terminate
  ];

  filterActive = names: filter (name: !(elem name disabledTests)) names;

  tests = mapAttrs
    (type: set:
      map
        (name:
          {
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

in builtins.foldl' (final: set: final // set) { } (tests.plugins ++ tests.colorschemes)
