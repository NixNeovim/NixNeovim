{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "PLUGIN_NAME";
  pluginUrl = "PLUGIN_URL";

  # only needed when the name of the name of the module/plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptions = {
    # add module options here
  };



in mkLuaPlugin {

# Consider the following additional options:
#
# extraDescription ? ""           # description added to the enable function
# extraPackages ? [ ]             # non-plugin packages
# extraConfigLua ? ""             # lua config added to the init.vim
# extraConfigVim ? ""             # vim config added to the init.vim
# defaultRequire ? true           # add default requrie string?
# extraOptions ? {}               # extra vim options like line numbers, etc
# extraNixNeovimConfig ? {}       # extra config applied to 'programs.nixneovim'
# isColorscheme ? false           # If enabled, plugin will be added to 'nixneovim.colorschemes' instead of 'nixneovim.plugins'
# configConverter ? camelToSnake  # Specify the config name converter, default expects camelCase and converts that to snake_case

  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
  ];
}
