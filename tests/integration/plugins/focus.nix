{ testHelper, lib }:

let
  name = "focus";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            autoresize = {
              width = 3;
              height = 7;
            };
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
            pkgs.writeText "init.lua-expected" /* lua */ ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  require('focus').setup {
                    ["autoresize"] = {
                      ["enable"] = true,
                      ["height"] = 7,
                      ["height_quickfix"] = 10,
                      ["minheight"] = 0,
                      ["minwidth"] = 0,
                      ["width"] = 3
                    },
                    ["commands"] = true,
                    ["split"] = {
                      ["bufnew"] = false,
                      ["tmux"] = false
                    }
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
