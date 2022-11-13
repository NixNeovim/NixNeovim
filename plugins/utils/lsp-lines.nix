{ pkgs, lib, config, ... }:

with lib;

let

  name = "lsp-lines";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
    onlyCurrentLine = boolOption false "Show virtual lines only for the current line's diagnostics";
  };

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
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
}
