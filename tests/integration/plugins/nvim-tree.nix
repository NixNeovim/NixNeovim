{ testHelper, lib }:

let
  name = "nvim-tree";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            view.width = "10";
            systemOpen.cmd = "test";
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
                  require('nvim-tree').setup {
                    ["diagnostics"] = { ["icons"] = {} },
                    ["filters"] = {},
                    ["git"] = {},
                    ["hijack_directories"] = {},
                    ["system_open"] = { ["cmd"] = "test" },
                    ["trash"] = {},
                    ["update_focused_file"] = {},
                    ["view"] = { ["width"] = "10" }
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

          check_nvim_start -c "${nvimTestCommand}"
        '';
      };
    };
}
