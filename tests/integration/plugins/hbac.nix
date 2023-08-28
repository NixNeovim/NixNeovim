{ testHelper, ... }:

let
  name = "hbac";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            closeBuffersWithWindows = true;
            autoclose = false;
            telescope.mappings.i.closeUnpinned = "<M-x>";
            telescope.mappings.i.deleteBuffer = "<M-c>";
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
                  require('hbac').setup {
                    ["autoclose"] = false,
                    ["close_buffers_with_windows"] = true,
                    ["telescope"] = { ["mappings"] = {
                        ["i"] = {
                          ["close_unpinned"] = "<M-x>",
                          ["delete_buffer"] = "<M-c>",
                          ["pin_all"] = "<M-a>",
                          ["toggle_selections"] = "<M-y>",
                          ["unpin_all"] = "<M-u>"
                        },
                        ["n"] = {
                          ["close_unpinned"] = "<M-c>",
                          ["delete_buffer"] = "<M-x>",
                          ["pin_all"] = "<M-a>",
                          ["toggle_selections"] = "<M-y>",
                          ["unpin_all"] = "<M-u>"
                        }
                      } },
                    ["threshold"] = 10
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
        '';
      };
    };
}
