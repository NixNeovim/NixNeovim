{ nixneovim, testHelper, ... }:
{
  neovim-test = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim = {
          enable = true;
          extraConfigVim = ''
            map j gj
          '';
          extraConfigLua = ''
            -- test lua comment
          '';

          plugins.numb.enable = true;
          mappings = {
            normalVisualOp = {
              "ßß" = "'@'";
              "<F2>" = "':LspStop<cr>'";
            };
          };
        };

        nmt.script = testHelper.moduleTest ''

          assertFileContains "$nvimFolder/init.lua" "vim.cmd [[source"
          vimscript=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))

          assertDiff $normalizedConfig ${
            pkgs.writeText "init.lua-expected" ''

vim.cmd [[source <nix-store-hash>-nvim-init-home-manager.vim]]

--------------------------------------------------
--                 Globals                      --
--------------------------------------------------

--------------------------------------------------
--                 Options                      --
--------------------------------------------------

--------------------------------------------------
--                 Keymappings                  --
--------------------------------------------------

do vim.keymap.set("", "<F2>", ':LspStop<cr>', { ["noremap"] = true }) end
do vim.keymap.set("", "ßß", '@', { ["noremap"] = true }) end

--------------------------------------------------
--               Extra Config (Lua)             --
--------------------------------------------------

-- config for plugin: numb
do
  function setup()

    require('numb').setup {
      ["centered_peeking"] = true,
      ["number_only"] = false,
      ["show_cursorline"] = true,
      ["show_numbers"] = true
    }

  end
  success, output = pcall(setup) -- execute 'setup()' and catch any errors
  if not success then
    print("Error on setup for plugin: numb")
    print(output)
  end
end

-- test lua comment
            ''
          }
        '';
      };
    };
}
