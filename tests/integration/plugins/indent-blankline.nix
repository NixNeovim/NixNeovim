{ testHelper, lib }:

let
  name = "indent-blankline";
  nvimTestCommand = ""; # Test command to check if plugin is loaded
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            indent = {
              char = "a";
              smartIndentCap = false;
              highlight = [ "#123456" "Statement" ];
            };
            scope.showStart = false;
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
                  local hooks = require "ibl.hooks"
                  -- create the highlight groups in the highlight setup hook, so they are reset
                  -- every time the colorscheme changes
                  hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                      vim.api.nvim_set_hl(0, "Ibl123456", { fg = "#123456" })
                  end)
                  
                  require('ibl').setup {
                    ["indent"] = {
                      ["char"] = "a",
                      ["highlight"] = {
                        "Ibl123456",
                        "Statement"
                      },
                      ["repeat_linebreak"] = true,
                      ["smart_indent_cap"] = false
                    },
                    ["scope"] = {
                      ["enabled"] = true,
                      ["show_end"] = true,
                      ["show_start"] = false
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
