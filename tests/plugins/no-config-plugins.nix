{ testHelper, ... }:

# Test all modules that have no config

{
  no-config-tests = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          git-messenger.enable = true;
          bufdelete.enable = true;
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$config" ${
            pkgs.writeText "no-config-plugins.expected" ''
              ${testHelper.config.start}

              ${testHelper.config.end}
            ''
          }
        '';
      };
    };
}
