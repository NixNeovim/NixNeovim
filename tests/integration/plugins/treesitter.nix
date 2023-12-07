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
            refactor = {
              highlightDefinitions = {
                enable = true;
                clearOnCursorMove = false;
              };
              highlightCurrentScope.enable = true;
              smartRename = {
                enable = true;
                keymaps.smartRename = "abc";
              };
              navigation.enable = true;
            };
          };
          ts-context-commentstring.enable = true;
          comment-frame.enable = true;
          treesitter-context.enable = true;
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "init.lua-expected" ''
              vim.cmd [[source <nix-store-hash>-nvim-init-home-manager.vim]]
              ${testHelper.config.start}

              -- config for plugin: ts-context-commentstring
              do
                function setup()

                  require('ts_context_commentstring').setup {}
                  vim.g.skip_ts_context_commentstring_module = true

                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: ts-context-commentstring")
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

              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  require('nvim-treesitter.configs').setup({
                    ["context_commentstring"] = { ["enable"] = false },
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
                    ["indent"] = { ["enable"] = false },
                    ["refactor"] = {
                      ["highlight_current_scope"] = { ["enable"] = true },
                      ["highlight_definitions"] = {
                        ["clear_on_cursor_move"] = false,
                        ["enable"] = true
                      },
                      ["navigation"] = {
                        ["enable"] = true,
                        ["keymaps"] = {
                          ["goto_definition"] = "gnd",
                          ["goto_next_usage"] = "<a-*>",
                          ["goto_previous_usage"] = "<a-#>",
                          ["list_definitions"] = "gnD",
                          ["list_definitions_toc"] = "gO"
                        }
                      },
                      ["smart_rename"] = {
                        ["enable"] = true,
                        ["keymaps"] = { ["smart_rename"] = "abc" }
                      }
                    }
                  })
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: ${name}")
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
          if grep -c 'ERROR' test.tmp # the -c flag counts mathing lines, simulates error code
          then
            neovim_error "$(cat test.tmp)"
          fi
        '';
      };
    };
}
