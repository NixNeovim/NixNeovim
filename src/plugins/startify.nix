{ pkgs, lib, helpers, config, ... }:
let

  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    toLuaObject;

  inherit (lib)
    types
    concatStringsSep
    mkOption;

  name = "startify";
  pluginUrl = "https://github.com/mhinz/vim-startify";

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
    bookmarks = listOption [] "A list of files or directories to bookmark. The list can contain two kinds of types. Either a path or a dictionary whereas the key is the custom index and the value is the path.";
    changeToDir = intOption 1 "When opening a file or bookmark, change to its directory";
    changeToVcsRoot = intOption 0 "When opening a file or bookmark, seek and change to the root directory of the VCS (if there is one).";
    changeCmd = enumOption [ "cd" "lcd" "tcd" ] "lcd" "The default command for switching directories";
    customheader = strOption "'startify#pad(startify#fortune#cowsay())'" "Define your own header.";
    enableSpecial = intOption 1 "Show <empty buffer> and <quit>";
    lists = listOption [] "Startify displays lists. Each list consists of a `type` and optionally a `header` and custom `indices`.";
    skiplist = listOption [] "A list of Vim regular expressions that is used to filter recently used files.";
    updateOldfiles = intOption 0 "Usually |v:oldfiles| only gets updated when Vim exits. Using this option updates it on-the-fly, so that :Startify is always up-to-date.";
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
    vim-startify
  ];
  moduleOptionsVimPrefix = "startify_";
  defaultRequire = false;
}
