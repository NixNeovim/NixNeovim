{ pkgs, lib, config, ... }:

with lib;

let

  name = "ts-context-commentstring";
  pluginUrl = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) boolOption;

  moduleOptions = {
    # add module options here
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-ts-context-commentstring
  ];
  defaultRequire = false;
}
