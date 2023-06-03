{ pkgs, lib, config, ... }:

with lib;

let

  name = "indent-blankline";
  pluginName = "indent_blankline";
  pluginUrl = "https://github.com/lukas-reineke/indent-blankline.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) boolNullOption strNullOption;

  moduleOptions = {
    # add module options here
    showCurrentContext = boolNullOption "";
    showCurrentContextStart = boolNullOption "";
    showEndOfLine = boolNullOption "";
    spaceCharBlankline = strNullOption "";
    showTrailingBlanklineIndent = boolNullOption "";
  };

in
with helpers;
mkLuaPlugin {
  inherit name pluginName moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    indent-blankline-nvim
  ];
}
