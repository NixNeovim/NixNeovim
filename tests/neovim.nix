{ nixneovim, ... }:
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

        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          assertFileContains "$nvimFolder/init.lua" "vim.cmd [[source"
          vimscript=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))
          config="$(_abs $nvimFolder/init.lua)"
          assertFileExists "$config"

          PATH=$PATH:$(_abs home-path/bin)
          HOME=$(realpath .) nvim -u "$config" -c 'qall' --headless
          echo # add missing \0 to output of 'nvim'

          # Replace the path the vimscript file, because it contains the hash
          sed "s/\/nix\/store\/[a-z0-9]\{32\}/\<nix-store-hash\>/" "$config" > normalizedConfig.lua

          assertDiff normalizedConfig.lua ${
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
