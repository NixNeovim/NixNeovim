{ testHelper, ... }:

let
  name = "rust-tools";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            # TODO: use mkRaw function
            server = { __raw =
              ''
                {
                  ["on_attach"] = function()
                    -- custom lsp code
                    -- custom rust-tools code
                  end
                }
              '';
            };
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
              vim.cmd [[source <nix-store-hash>-nvim-init-home-manager.vim]]
              ${testHelper.config.start}

              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  require('rust-tools').setup {
                    ["dap"] = { ["adapter"] = {
                        ["command"] = "lldb-vscode",
                        ["name"] = "rt_lldb",
                        ["type"] = "executable"
                      } },
                    ["server"] = {
                      ["on_attach"] = function()
                        -- custom lsp code
                        -- custom rust-tools code
                      end
                    }
                    ,
                    ["tools"] = {
                      ["crate_graph"] = {
                        ["backend"] = "x11",
                        ["enabled_graphviz_backends"] = {
                          "bmp",
                          "cgimage",
                          "canon",
                          "dot",
                          "gv",
                          "xdot",
                          "xdot1.2",
                          "xdot1.4",
                          "eps",
                          "exr",
                          "fig",
                          "gd",
                          "gd2",
                          "gif",
                          "gtk",
                          "ico",
                          "cmap",
                          "ismap",
                          "imap",
                          "cmapx",
                          "imap_np",
                          "cmapx_np",
                          "jpg",
                          "jpeg",
                          "jpe",
                          "jp2",
                          "json",
                          "json0",
                          "dot_json",
                          "xdot_json",
                          "pdf",
                          "pic",
                          "pct",
                          "pict",
                          "plain",
                          "plain-ext",
                          "png",
                          "pov",
                          "ps",
                          "ps2",
                          "psd",
                          "sgi",
                          "svg",
                          "svgz",
                          "tga",
                          "tiff",
                          "tif",
                          "tk",
                          "vml",
                          "vmlz",
                          "wbmp",
                          "webp",
                          "xlib",
                          "x11"
                        },
                        ["full"] = true
                      },
                      ["hover_actions"] = { ["auto_focus"] = false },
                      ["inlay_hints"] = {
                        ["auto"] = true,
                        ["highlight"] = "Comment",
                        ["max_len_align"] = false,
                        ["max_len_align_padding"] = 1,
                        ["only_current_line"] = false,
                        ["other_hints_prefix"] = "=> ",
                        ["parameter_hints_prefix"] = "<- ",
                        ["right_align"] = false,
                        ["right_align_padding"] = 7,
                        ["show_parameter_hints"] = true
                      },
                      ["reload_workspace_from_cargo_toml"] = true
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

              -- config for plugin: lspconfig
              do
                function setup()

                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: lspconfig")
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
