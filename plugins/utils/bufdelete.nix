{ pkgs, lib, config, ... }:

with lib;

let

  name = "bufdelete";
  pluginUrl = "https://github.com/famiu/bufdelete.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };

  moduleOptions = with helpers; {
    # add module options here
  };

  inherit (helpers.toLua)
    mkLuaPlugin;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    bufdelete-nvim
  ];
  defaultRequire = false;
}
