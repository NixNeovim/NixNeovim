{ testHelper, lib }:

let
  name = "zig-env";
  nvimTestCommand = ""; # Test command to check if plugin is loaded (optional)
in {
  "${name}-test" = { config, lib, pkgs, ... }:

    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
            enable = true;
            lsp = true;
            fmtAutosave = 1;
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
            pkgs.writeText "init.lua-expected" /* lua */ ''
              vim.cmd [[source <nix-store-hash>-nvim-init-home-manager.vim]]

              ${testHelper.config.start}

              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  vim.g.zig_fmt_autosave = 1
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
                  do -- lsp server config zls
                    local setup =  {
                      on_attach = function(client, bufnr)
                      end,
                    }
                    require('lspconfig')["zls"].setup(setup)
                  end -- lsp server config zls
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

          check_nvim_start -c "${nvimTestCommand}"

          lang=zig
          echo "Test lsp for filetype $lang"
          start_nvim -c "lua vim.lsp.set_log_level('debug')" -c "set filetype=$lang" -c 'LspInfo' -c 'silent w! tmp.lsp.out' 2> /dev/null
          if [ "$(grep -oP '(?<=cmd is executable: )true' tmp.lsp.out)" != "true" ]
          then
            echo "Could not execute lsp server for \"$lang\""
            exit 1
          fi
        '';
      };
    };
}
