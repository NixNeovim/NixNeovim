{ testHelper, ... }:

let
  name = "gruvbox-baby";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.colorschemes = {
          "${name}" = {
            enable = true;
            backgroundColor = "dark";
            transparentMode = true;
            extraLua.pre = ''
              -- test lua pre comment
            '';
            extraLua.post = ''
              -- test lua post comment
            '';
          };
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$config" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  vim.g.gruvbox_baby_background_color = "dark"
                  vim.g.gruvbox_baby_transparent_mode = true
                  vim.g.gruvboy_baby_comment_style = "italic"
                  vim.g.gruvboy_baby_keyword_style = "italic"
                  vim.g.gruvboy_baby_string_style = "nocombine"
                  vim.g.gruvboy_baby_function_style = "bold"
                  vim.g.gruvboy_baby_variable_style = "NONE"
                  vim.g.gruvboy_baby_highlights = {}
                  vim.g.gruvboy_baby_color_overrides = {}
                  vim.g.gruvboy_baby_use_original_palette = false

                  vim.cmd[[colorscheme gruvbox-baby]]
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

          check_colorscheme ${name}
        '';
      };
    };
}
