{ testHelper, ... }:

let
  name = "markdown-preview";
in {
  "${name}-test" = { config, lib, pkgs, ... }:
    {
      config = {

        programs.nixneovim.plugins = {
          "${name}" = {
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
          assertDiff "$config" ${
            pkgs.writeText "init.lua-expected" ''
              ${testHelper.config.start}
              -- config for plugin: ${name}
              do
                function setup()
                  -- test lua pre comment
                  vim.g.mkdp_auto_start = false
                  vim.g.mkdp_auto_close = true
                  vim.g.mkdp_refresh_slow = false
                  vim.g.mkdp_command_for_global = false
                  vim.g.mkdp_open_to_the_world = false
                  vim.g.mkdp_open_ip = ""
                  vim.g.mkdp_browser = ""
                  vim.g.mkdp_echo_preview_url = false
                  vim.g.mkdp_browserfunc = ""
                  vim.g.mkdp_markdown_css = ""
                  vim.g.mkdp_highlight_css = ""
                  vim.g.mkdp_port = ""
                  vim.g.mkdp_page_title = "「$${name} 」"
                  vim.g.mkdp_filetypes = {
                    "markdown"
                  }
                  vim.g.mkdp_theme = "dark"
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
        '';
      };
    };
}
