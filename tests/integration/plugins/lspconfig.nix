{ testHelper, ... }:

let
  name = "lspconfig";
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
              clangd.enable = true;
              nil.enable = false; # FIX: throws '[LSP] No client with id 1' if activated
              ruff-lsp.enable = true;
              svelte-language-server.enable = true;
              typescript-language-server.enable = true;
            };
            # extraLua.pre = ''
              # -- test lua pre comment
            # '';
            # extraLua.post = ''
              # -- test lua post comment
            # '';
          };
        };

        # programs.nixneovim.extraPackages = [
          # pkgs.ruff-lsp
        # ];

        nmt.script = testHelper.moduleTest ''
          assertDiff "$normalizedConfig" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: lspconfig
              do
                function setup()

                  local on_attach_global = function(client, bufnr)
                    -- test comment
                  end

                  do -- lsp server config clangd

                    local setup =  {
                      on_attach = function(client, bufnr)
                        on_attach_global(client, bufnr)
                      end,
                    }

                    require('lspconfig')["clangd"].setup(setup)
                  end -- lsp server config clangd

                  do -- lsp server config ruff-lsp
                   local setup =  {
                     on_attach = function(client, bufnr)
                       on_attach_global(client, bufnr)

                     end,

                   }

                     require('lspconfig')["ruff_lsp"].setup(setup)
                   end -- lsp server config ruff-lsp

                  do -- lsp server config rust-analyzer

                    local on_attach_client = function(client, bufnr)
                      -- test comment extra
                    end

                    local setup =  {
                      on_attach = function(client, bufnr)
                        on_attach_global(client, bufnr)
                        on_attach_client(client, bufnr)
                      end,
                    }

                    require('lspconfig')["rust_analyzer"].setup(setup)
                  end -- lsp server config rust-analyzer

                  do -- lsp server config svelte-language-server

                    local setup =  {
                     on_attach = function(client, bufnr)
                       on_attach_global(client, bufnr)
                     end,
                    }

                    require('lspconfig')["svelte"].setup(setup)
                 end -- lsp server config svelte-language-server

                 do -- lsp server config typescript-language-server

                   local setup =  {
                     on_attach = function(client, bufnr)
                       on_attach_global(client, bufnr)
                     end,
                   }

                   require('lspconfig')["tsserver"].setup(setup)
                 end -- lsp server config typescript-language-server

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
          # List of all filetypes (as recognised by neovim) this test should check
          for lang in c svelte typescript rust # TODO: add 'nix'
          do
            echo "Test lsp for filetype $lang"
            start_nvim -c "lua vim.lsp.set_log_level('debug')" -c "set filetype=$lang" -c 'LspInfo' -c 'silent w! tmp.lsp.out'
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
