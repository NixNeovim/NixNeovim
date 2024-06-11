{ pkgs, lib, helpers, ... }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "vim-one";
  pluginUrl = "https://github.com/rakr/vim-one";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptions = {
    # add module options here
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    vim-one
  ];

  extraNixNeovimConfig = {
    termguicolors = true;
  };

  isColorscheme = true;
  extraConfigLua = "vim.cmd('colorscheme one')";
}
