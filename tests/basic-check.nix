{ testHelper, ... }:

# This module performs a very basic check for all available plugins
# It only confirms that there are no errors on startup, when the respective
# module is enabled. This does not check that the plugins is actually loaded
# or otherwise working as intended

{
  basic-check-test = { config, lib, pkgs, ... }:
    {
      config =
        let
          plugins = config.programs.nixneovim.plugins;
        in {
          # enable all plugins
          programs.nixneovim.plugins =
            let

              filteredPlugins =
                lib.filterAttrs
                (k: v:
                  let
                    firstChar = lib.head (lib.stringToCharacters k);
                  in firstChar == "a")
                  plugins;

              autoPlugins = lib.mapAttrs
                (k: v: { enable = true; })
                filteredPlugins;

              # Some plugins are correctly loaded
              # Therefore, we have to load them manually here
              pluginsWithErrors = {
                nvim-cmp.snippet.enable = true;
              };
            in autoPlugins // pluginsWithErrors;
          nmt.script = testHelper.moduleTest ''
          '';

        };
    };
}
