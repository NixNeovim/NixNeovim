{ testHelper, lib }:

let
  name = "wilder";
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
                  require('wilder').setup {
                    ["accept_completion_auto_select"] = true,
                    ["accept_key"] = "<Down>",
                    ["enable_cmdline_enter"] = true,
                    ["modes"] = {
                      "/",
                      "?"
                    },
                    ["next_key"] = "<Tab>",
                    ["prev_key"] = "<S-Tab>",
                    ["reject_key"] = "<Up>",
                    ["wildcharm"] = "&wildchar"
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
