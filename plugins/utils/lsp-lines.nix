{ pkgs, lib, config, ... }:

with lib;

let

  name = "lsp-lines";
  pluginUrl = "https://sr.ht/~whynothugo/lsp_lines.nvim/";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.customOptions) boolOption;
  
  moduleOptions = {
    # add module options here
    onlyCurrentLine = boolOption false "Show virtual lines only for the current line's diagnostics";
  };

in
with helpers;
mkLuaPlugin {
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
