{ pkgs, lib, config, helpers, ... }:

with lib;

let

  name = "bufdelete";
  pluginUrl = "https://github.com/famiu/bufdelete.nvim";

  moduleOptions = with helpers; {
    # add module options here
  };

  inherit (helpers.generator)
    mkLuaPlugin;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    bufdelete-nvim
  ];
  defaultRequire = false;
}
