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
          programs.nixneovim.plugins =
            lib.mapAttrs
              (k: v:
                {
                  ${k}.enable = true;
                }
              ) plugins;
          nmt.script = testHelper.moduleTest ''
          '';

        };
    };
}
