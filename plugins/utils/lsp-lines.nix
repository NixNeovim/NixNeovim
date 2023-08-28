{ pkgs, lib, helpers, config }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.utils)
    optionalString;

  name = "lsp-lines";
  pluginUrl = "https://sr.ht/~whynothugo/lsp_lines.nvim/";

  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.custom_options) boolOption;
  
  moduleOptions = {
    # add module options here
    onlyCurrentLine = boolOption false "Show virtual lines only for the current line's diagnostics";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    lsp-lines-nvim
  ];
  extraConfigLua = ''
    require('lsp_lines').setup()

    -- Disable virtual_text since it's redundant due to lsp_lines.
    vim.diagnostic.config({
      virtual_text = false,
    })

    ${optionalString cfg.onlyCurrentLine "vim.diagnostic.config({ virtual_lines = { only_current_line = true } })"}
  '';
  defaultRequire = false;
}
