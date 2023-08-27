{ pkgs, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "git-messenger";
  pluginUrl = "https://github.com/rhysd/git-messenger.vim";

  # TODO: add options for plugin config (needs changes to mkLuaPlugin)

in mkLuaPlugin {
  inherit name pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    git-messenger-vim
  ];
  defaultRequire = false;
}
