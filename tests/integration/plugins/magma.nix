{ testHelper, lib }:

let
  name = "magma";
  nvimTestCommand = ""; # Test command to check if plugin is loaded
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            imageProvider = "ueberzug";
            wrapOutput = false;
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
                    vim.g.magma_automatically_open_output = true
                    vim.g.magma_cell_highlight_group = "CursorLine"
                    vim.g.magma_image_provider = "ueberzug"
                    vim.g.magma_output_window_borders = true
                    vim.g.magma_save_path = ' '
                    vim.g.magma_show_mimetype_debug = false
                    vim.g.magma_wrap_output = false

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
