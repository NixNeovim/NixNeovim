{ testHelper, ... }:

let
  name = "lsp";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            onAttach = "-- test comment";
            servers = {
              rust-analyzer = {
                enable = true;
                onAttachExtra = "-- test comment extra";
              };
              rnix-lsp.enable = true;
              clangd.enable = true;
              nil.enable = false; # FIX: throws weired error if activated
            };
            # extraLua.pre = ''
              # -- test lua pre comment
            # '';
            # extraLua.post = ''
              # -- test lua post comment
            # '';
          };
        };

        nmt.script = testHelper.moduleTest ''
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: lsp
              do
                function setup()

                  do -- lsp server config clangd
                    local __on_attach_base = function(client, bufnr)
                      -- test comment
                    end

                    local __setup =  {
                      on_attach = function(client, bufnr)
                        __on_attach_base(client, bufnr)
                      end,
                    }

                    require('lspconfig')["clangd"].setup(__setup)
                  end -- lsp server config clangd

                  do -- lsp server config rnix-lsp
                    local __on_attach_base = function(client, bufnr)
                      -- test comment
                    end

                    local __setup =  {
                      on_attach = function(client, bufnr)
                        __on_attach_base(client, bufnr)
                      end,
                    }

                    require('lspconfig')["rnix"].setup(__setup)
                  end -- lsp server config rnix-lsp

                  do -- lsp server config rust-analyzer
                    local __on_attach_base = function(client, bufnr)
                      -- test comment
                    end

                    local __on_attach_extra = function(client, bufnr)
                      -- test comment extra
                    end

                    local __setup =  {
                      on_attach = function(client, bufnr)
                        __on_attach_base(client, bufnr)
                        __on_attach_extra(client, bufnr)
                      end,
                    }

                    require('lspconfig')["rust_analyzer"].setup(__setup)
                  end -- lsp server config rust-analyzer

                end
                success, output = pcall(setup) -- execute 'setup()' and catch any errors
                if not success then
                  print("Error on setup for plugin: lsp")
                  print(output)
                end
              end
              ${testHelper.config.end}
            ''
          }
          for lang in rust c nix svelte
          do
            echo "Test lsp for filetype $lang"
            start_vim -c "set filetype=$lang" -c 'LspInfo' -c 'silent w! tmp.lsp.out'
            if [ "$(grep -oP '(?<=cmd is executable: )true' tmp.lsp.out)" != "true" ]
            then
              echo "Could not execute lsp server for \"$lang\""
              exit 1
            fi
          done
        '';
      };
    };
}
