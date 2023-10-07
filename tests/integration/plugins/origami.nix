{ testHelper, lib }:

let
  name = "origami";
  nvimTestCommand = ""; # Test command to check if plugin is loaded
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            keepFoldsAcrossSessions = false;
            pauseFoldsOnSearch = true;
            setupFoldKeymaps = false;
            extraLua.pre = ''
              -- test lua pre comment
            '';
            extraLua.post = ''
              -- test lua post comment
            '';
          };
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  require('origami').setup {
                    ["keepFoldsAcrossSessions"] = false,
                    ["pauseFoldsOnSearch"] = true,
                    ["setupFoldKeymaps"] = false
                  }
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: ${name}")
                  print(output)
                end
              end
              ${testHelper.config.end}
            ''
          }

          start_vim -c "${nvimTestCommand}"
        '';
      };
    };
}
