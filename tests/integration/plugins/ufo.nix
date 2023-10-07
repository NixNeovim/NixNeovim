{ testHelper, lib }:

let
  name = "ufo";
  nvimTestCommand = ""; # Test command to check if plugin is loaded
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
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
                    require('ufo').setup {}
                    vim.o.foldcolumn = '1' -- '0' is not bad
                    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
                    vim.o.foldlevelstart = 99
                    vim.o.foldenable = true
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
