{ testHelper, lib }:

let
  name = "clangd-extensions";
  nvimTestCommand = ""; # Test command to check if plugin is loaded
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            inlayHints.inline = { __raw = null; };
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
                  require('clangd_extensions').setup {
                    ["ast"] = {
                      ["highlights"] = { ["detail"] = "Comment" },
                      ["kind_icons"] = {
                        ["compound"] = "🄲",
                        ["packexpansion"] = "🄿",
                        ["recovery"] = "🅁",
                        ["templateparamobject"] = "🅃",
                        ["templatetemplateparm"] = "🅃",
                        ["templatetypeparm"] = "🅃",
                        ["translationunit"] = "🅄"
                      },
                      ["role_icons"] = {
                        ["declaration"] = "🄓",
                        ["expression"] = "🄔",
                        ["specifier"] = "🄢",
                        ["statement"] = ";",
                        ["template argument"] = "🆃",
                        ["type"] = "🄣"
                      }
                    },
                    ["inlay_hints"] = {
                      ["highlight"] = "Comment",
                      ["inline"] = nil,
                      ["max_len_align"] = false,
                      ["max_len_align_padding"] = 1,
                      ["only_current_line"] = false,
                      ["only_current_line_autocmd"] = {
                        "CursorHold"
                      },
                      ["other_hints_prefix"] = "=> ",
                      ["parameter_hints_prefix"] = "<- ",
                      ["priority"] = 100,
                      ["right_align"] = false,
                      ["right_align_padding"] = 7,
                      ["show_parameter_hints"] = true
                    },
                    ["memory_usage"] = { ["border"] = "none" },
                    ["symbol_info"] = { ["border"] = "none" }
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
