{ testHelper, pkgs }:
{
  config = {

    programs.nixneovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
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
      augroups = {
        highlightOnYank = {
          autocmds = [{
            event = "TextYankPost";
            pattern = "*";
            luaCallback = ''
              vim.highlight.on_yank {
                higroup = (
                  vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
                ),
                timeout = 200,
              }
            '';
          }];
        };
      };
    };

    nmt.script = testHelper.moduleTest ''

      echo "Starting neovim via 'vi'"
      HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) vi -u $config --headless -c 'qall' 2>&1

      echo "Starting neovim via 'vim'"
      HOME=$(realpath .) XDG_CACHE_HOME=$(realpath ./cache) vim -u $config --headless -c 'qall' 2>&1

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
--                 Augroups                     --
--------------------------------------------------

do
  local group = vim.api.nvim_create_augroup("highlightOnYank", { ["clear"] = true })
  do
  local events = {"TextYankPost"}
  local opts = {
  ["callback"] = function(opts)
  vim.highlight.on_yank {
  higroup = (
    vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
  ),
  timeout = 200,
}

end
,
  ["group"] = group,
  ["nested"] = false,
  ["once"] = false,
  ["pattern"] = "*"
}
  vim.api.nvim_create_autocmd(events, opts)
end

end

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
}
