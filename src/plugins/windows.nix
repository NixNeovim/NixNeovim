{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "windows";
  pluginUrl = "https://github.com/anuvyklack/windows.nvim";

  moduleOptions = with helpers; {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
    # todo:
    # animations = boolOption true "Enable animations";
  };

in helpers.generator.mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    windows-nvim
    middleclass
  ];
  extraConfigLua = "require('${name}').setup()"; # ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
