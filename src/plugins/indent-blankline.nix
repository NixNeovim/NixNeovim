{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "indent-blankline";
  pluginName = "ibl";
  pluginUrl = "https://github.com/lukas-reineke/indent-blankline.nvim";

  inherit (helpers.custom_options) boolNullOption strNullOption;

  moduleOptions = {
    # add module options here
    showCurrentContext = boolNullOption "";
    showCurrentContextStart = boolNullOption "";
    showEndOfLine = boolNullOption "";
    spaceCharBlankline = strNullOption "";
    showTrailingBlanklineIndent = boolNullOption "";
  };

in mkLuaPlugin {
  inherit name pluginName moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    indent-blankline-nvim
  ];
}
