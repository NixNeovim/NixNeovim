{ pkgs, helpers, lib, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "endwise";
  pluginUrl = "https://github.com/tpope/vim-endwise";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

in mkLuaPlugin {
  inherit name pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    vim-endwise
  ];
  defaultRequire = false;
}
