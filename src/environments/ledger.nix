{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "ledger";
  pluginUrl = "https://github.com/ledger/vim-ledger/";

  # only needed when the name of the name of the module/plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # pluginName = ""

  inherit (lib)
    toLower;

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptionsVim = {
    # add module options here
    maxwidth = intOption 80 "Number of columns to display foldtext";
    fillstring = strOption "    -" "String used to fill the space between account name and amount in the foldtext";
    detailedFirst = boolOption true "Account completion sorted by depth instead of alphabetically";
    foldBlanks = boolOption false "Hide blank lines following a transaction on a fold";
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
    vim-ledger
  ];
  defaultRequire = false;
  moduleOptionsVimPrefix = "ledger_";
}
