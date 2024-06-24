{ testHelper, ... }:

let
  name = "bamboo";
  nvimTestCommand = "colorscheme bamboo"; # Test command to check if plugin is loaded
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.colorschemes = {
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
                  require('bamboo').setup {
                    ["cmp_itemkind_reverse"] = false,
                    ["code_style"] = {
                      ["comments"] = "italic",
                      ["functions"] = "none",
                      ["keywords"] = "none",
                      ["strings"] = "none",
                      ["variables"] = "none"
                    },
                    ["diagnostics"] = {
                      ["background"] = true,
                      ["darker"] = false,
                      ["undercurl"] = true
                    },
                    ["ending_tildes"] = false,
                    ["lualine"] = { ["transparent"] = false },
                    ["style"] = "vulgaris",
                    ["term_colors"] = true,
                    ["toggle_style_list"] = {
                      "vulgaris",
                      "multiplex"
                    },
                    ["transparent"] = false
                  }
                  vim.cmd[[ colorscheme bamboo ]]
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
