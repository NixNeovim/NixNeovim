{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "comment-frame";
  pluginName = "nvim-comment-frame";
  pluginUrl = "https://github.com/s1n7ax/nvim-comment-frame";

  inherit (helpers.custom_options)
    strOption
    intOption
    boolOption;

  inherit (helpers.generator)
    mkLuaPlugin;

  moduleOptions = {
    # add module options here
    keymap = strOption "<leader>cc" "";
    multiline_keymap = strOption "<leader>C" "";
    disableDefaultKeymap = boolOption false "";
    startStr = strOption "//" "";
    endStr = strOption "//" "";
    fillChar = strOption "-" "";
    frameWidth = intOption 70 "";
    lineWrapLen = intOption 50 "";
    autoIndent = boolOption true "";
    addCommentAbove = boolOption true "";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginName pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-comment-frame
    pkgs.vimPlugins.nvim-treesitter
  ];
}
