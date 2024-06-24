{ testHelper, ... }:

let
  name = "lspsaga";
  nvimTestCommand = "Lspsaga diagnostic_jump_next";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            lightbulb.enable = false;
            lightbulb.sign = false;
            finder.keys.jumpTo = "a";
            finder.keys.split = "a";
            symbolInWinbar.enable = false;
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
                  require('lspsaga').setup {
                    ["beacon"] = {
                      ["enable"] = true,
                      ["frequency"] = 7
                    },
                    ["callhierarchy"] = {
                      ["keys"] = {
                        ["edit"] = "e",
                        ["expand_collapse"] = "u",
                        ["jump"] = "o",
                        ["quit"] = "q",
                        ["split"] = "i",
                        ["tabe"] = "t",
                        ["vsplit"] = "s"
                      },
                      ["show_detail"] = false
                    },
                    ["code_action"] = {
                      ["extend_gitsigns"] = false,
                      ["keys"] = {
                        ["exec"] = "<CR>",
                        ["quit"] = "q"
                      },
                      ["num_shortcut"] = true
                    },
                    ["definition"] = {
                      ["edit"] = "<C-c>o",
                      ["quit"] = "q",
                      ["split"] = "<C-c>i",
                      ["tabe"] = "<C-c>t",
                      ["vsplit"] = "<C-c>v"
                    },
                    ["diagnostic"] = {
                      ["jump_num_shortcut"] = true,
                      ["keys"] = {
                        ["exec_action"] = "o",
                        ["expand_or_jump"] = "<CR>",
                        ["quit"] = "q",
                        ["quit_in_show"] = {
                          "q",
                          "<ESC>"
                        }
                      },
                      ["show_code_action"] = true,
                      ["show_source"] = true
                    },
                    ["finder"] = { ["keys"] = {
                        ["close_in_preview"] = "<ESC>",
                        ["expand_or_jump"] = "o",
                        ["jump_to"] = "a",
                        ["quit"] = {
                          "q",
                          "<ESC>"
                        },
                        ["split"] = "a",
                        ["tabe"] = "t",
                        ["tabnew"] = "r",
                        ["vsplit"] = "s"
                      } },
                    ["hover"] = {
                      ["open_browser"] = "!chrome",
                      ["open_link"] = "gx"
                    },
                    ["lightbulb"] = {
                      ["enable"] = false,
                      ["enable_in_insert"] = true,
                      ["sign"] = false,
                      ["virtual_text"] = true
                    },
                    ["outline"] = {
                      ["auto_close"] = true,
                      ["auto_preview"] = true,
                      ["auto_refresh"] = true,
                      ["auto_resize"] = false,
                      ["close_after_jump"] = false,
                      ["keys"] = {
                        ["expand_or_jump"] = "o",
                        ["quit"] = "q"
                      },
                      ["win_position"] = "right"
                    },
                    ["preview"] = {
                      ["lines_above"] = 0,
                      ["lines_below"] = 10
                    },
                    ["rename"] = {
                      ["exec"] = "<CR>",
                      ["in_select"] = true,
                      ["quit"] = "<C-c>"
                    },
                    ["request_timeout"] = 2000,
                    ["scroll_preview"] = {
                      ["scroll_down"] = "<C-f>",
                      ["scroll_up"] = "<C-b>"
                    },
                    ["symbol_in_winbar"] = {
                      ["color_mode"] = true,
                      ["enable"] = false,
                      ["separator"] = " ",
                      ["show_file"] = true
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
