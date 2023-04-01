{ pkgs, lib, config, ... }:

with lib;

let

  name = "git-messenger";
  pluginUrl = "https://github.com/rhysd/git-messenger.vim";

  helpers = import ../../helper { inherit pkgs lib config; };

  # TODO: add options for plugin config (needs changes to mkLuaPlugin)

in
with helpers;
mkLuaPlugin {
  inherit name pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    git-messenger-vim
  ];
  defaultRequire = false;
}
