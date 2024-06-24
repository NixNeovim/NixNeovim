{ testHelper, lib }:

let
  name = "tokyonight";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.colorschemes = {
          "${name}" = {
            enable = true;
            style = "night";
            darkSidebar = true;
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
                  require('tokyonight').setup {
                    ["dark_float"] = false,
                    ["dark_sidebar"] = true,
                    ["hide_inactive_statusline"] = false,
                    ["italic_comments"] = false,
                    ["italic_functions"] = false,
                    ["italic_keywords"] = false,
                    ["italic_variables"] = false,
                    ["lualine_bold"] = false,
                    ["style"] = "night",
                    ["terminal_colors"] = false,
                    ["transparent"] = false,
                    ["transparent_sidebar"] = false
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
