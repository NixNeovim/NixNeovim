{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "ts-context-commentstring";
  pluginName = "ts_context_commentstring";
  pluginUrl = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring";

  inherit (helpers.custom_options) boolOption;

  moduleOptions = {
    # add module options here
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl pluginName;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-ts-context-commentstring
  ];
  defaultRequire = true;

  extraConfigLua = ''
    vim.g.skip_ts_context_commentstring_module = true
  '';

  extraNixNeovimConfig = {
    plugins.treesitter.enable = true;
  };
}
