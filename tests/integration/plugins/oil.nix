{ testHelper, ... }:

{
  oil-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          oil = {
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
            pkgs.writeText "oil.expected" ''
              ${testHelper.config.start}
              -- config for plugin: oil
              do
                function setup()
                  -- test lua pre comment
                  require('oil').setup {
                    ["buf_options"] = { ["buflisted"] = false },
                    ["columns"] = {
                      "icon"
                    },
                    ["default_file_explorer"] = true,
                    ["delete_to_trash"] = false,
                    ["float"] = {
                      ["border"] = "rounded",
                      ["max_height"] = 0,
                      ["max_width"] = 0,
                      ["padding"] = 2,
                      ["win_options"] = { ["winblend"] = 10 }
                    },
                    ["preview"] = {
                      ["border"] = "rounded",
                      ["max_height"] = {
                        0.900000
                      },
                      ["max_width"] = {
                        0.900000
                      },
                      ["min_height"] = {
                        5,
                        0.100000
                      },
                      ["min_width"] = {
                        40,
                        0.400000
                      },
                      ["win_options"] = { ["winblend"] = 0 }
                    },
                    ["progress"] = {
                      ["border"] = "rounded",
                      ["max_height"] = {
                        10,
                        0.900000
                      },
                      ["max_width"] = {
                        0.900000
                      },
                      ["min_height"] = {
                        5,
                        0.100000
                      },
                      ["min_width"] = {
                        40,
                        0.400000
                      },
                      ["minimized_border"] = "none",
                      ["win_options"] = { ["winblend"] = 0 }
                    },
                    ["prompt_save_on_select_new_entry"] = true,
                    ["restore_win_options"] = true,
                    ["skip_confirm_for_simple_edits"] = false,
                    ["use_default_keymaps"] = true,
                    ["view_options"] = { ["show_hidden"] = false },
                    ["win_options"] = {
                      ["concealcursor"] = "n",
                      ["conceallevel"] = 3,
                      ["cursorcolumn"] = false,
                      ["foldcolumn"] = "0",
                      ["list"] = false,
                      ["signcolumn"] = "no",
                      ["spell"] = false,
                      ["wrap"] = false
                    }
                  }
                  -- test lua post comment
                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: oil")
                  print(output)
                end
              end
              ${testHelper.config.end}
            ''
          }
        '';
      };
    };
}
