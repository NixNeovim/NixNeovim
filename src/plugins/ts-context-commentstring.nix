{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "ts-context-commentstring";
  pluginUrl = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring";

  inherit (helpers.custom_options) boolOption;

  moduleOptions = {
    # add module options here
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-ts-context-commentstring
  ];
  defaultRequire = false;
}
