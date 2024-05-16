{ pkgs, lib, helpers, ... }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "goyo";
  pluginUrl = "https://github.com/junegunn/goyo.vim";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptionsVim = {
    # add module options here
    width = intOption 80 "";
    height = intOption 85 "";
    linenr = intOption 0 "Show line numbers when in Goyo mode";
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

  inherit name moduleOptionsVim pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    goyo-vim
  ];
  moduleOptionsVimPrefix = "goyo_";
  defaultRequire = false;
}
