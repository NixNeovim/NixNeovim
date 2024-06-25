{ pkgs, lib, helpers, ... }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "typst-conceal";
  pluginUrl = "https://github.com/MrPicklePinosaur/typst-conceal.vim";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  pluginName = "typst_conceal";

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptionsVim = {
    # add module options here
    math = intOption 1 "Conseal text to math symbols";
    emoji = intOption 1 "Conseal text to emojis";
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
# moduleOptions                   # define (lua) configuration options for the plugin here
# moduleOptionsVim                # define (vim) configuration options for the plugin here
# moduleOptionsVimPrefix          # when using 'moduleOptionsVim' you can use this to define the options prefix. For example, "NERD" (for NerdCommenter), or "ledger_" (for ledger)

  inherit name moduleOptionsVim pluginUrl pluginName;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    typst-conceal-vim
  ];
  defaultRequire = false;
  extraConfigLua = "vim.opt.conceallevel = 2";
}
