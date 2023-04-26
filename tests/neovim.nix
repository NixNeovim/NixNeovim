{
  config = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim = {
          enable = true;

          plugins.numb.enable = true;
        };

        nmt.script = ''
          nvimFolder="home-files/.config/nvim"
          assertFileContains "$nvimFolder/init.lua" "vim.cmd [[source"
          file=$(grep "/nix/store.*\.vim" -o $(_abs $nvimFolder/init.lua))
          # cat $file
          assertFileExists $file
          assertFileContent "$file" ${
            pkgs.writeText "init.lua-expected" ''
lua <<EOF

--------------------------------------------------
--                 Globals                      --
--------------------------------------------------



--------------------------------------------------
--                 Keymappings                  --
--------------------------------------------------



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
    print(output)
  end
end





EOF
            ''
          }
        '';
      };
    };
}
