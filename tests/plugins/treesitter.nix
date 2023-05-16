{ testHelper, ... }:

let
  name = "treesitter";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        # This module tests nvim-treesitter and related plugins

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            installAllGrammars = true;
            extraLua.pre = ''
              -- test lua pre comment
            '';
            extraLua.post = ''
              -- test lua post comment
            '';
          };
          comment-frame.enable = true;
          ts-context-commentstring.enable = true;
          treesitter-context.enable = true;
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$config" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  require('nvim-treesitter.configs').setup({
                    ["highlight"] = { ["enable"] = true },
                    ["incremental_selection"] = {
                      ["enable"] = false,
                      ["keymaps"] = {
                        ["init_selection"] = "gnn",
                        ["node_decremental"] = "grm",
                        ["node_incremental"] = "grn",
                        ["scope_incremental"] = "grc"
                      }
                     },
                     ["indent"] = { ["enable"] = false }
                  })
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: ${name}")
                  print(output)
                end
              end

              -- config for plugin: treesitter-context
              do
                function setup()

                  require('treesitter-context').setup {
                    ["mode"] = "cursor",
                    ["patterns"] = { ["default"] = {
                        "class",
                        "function",
                        "method"
                      } },
                    ["trim_scope"] = "outer"
                  }

                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: treesitter-context")
                  print(output)
                end
              end

              -- config for plugin: comment-frame
              do
                function setup()

                  require('nvim-comment-frame').setup {
                    ["add_comment_above"] = true,
                    ["auto_indent"] = true,
                    ["disable_default_keymap"] = false,
                    ["end_str"] = "//",
                    ["fill_char"] = "-",
                    ["frame_width"] = 70,
                    ["keymap"] = "<leader>cc",
                    ["line_wrap_len"] = 50,
                    ["multiline_keymap"] = "<leader>C",
                    ["start_str"] = "//"
                  }

                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: comment-frame")
                  print(output)
                end
              end

              ${testHelper.config.end}
            ''
          }

          start_vim -c "silent checkhealth nvim-treesitter" -c 'silent w test.tmp'
          if grep -c 'ERROR' test.tmp # -c counts mathing lines, simulates error code
          then
            neovim_error "$(cat test.tmp)"
          fi
        '';
      };
    };
}
