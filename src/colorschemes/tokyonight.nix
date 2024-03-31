{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "tokyonight";
  pluginUrl = "https://github.com/folke/tokyonight.nvim";

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

  inherit (lib)
    mkOption
    mkEnableOption
    types;

  moduleOptions = {
    # add module options here
    style = enumOption [ "storm" "night" "day" ] "storm" "Theme style";
    # test = boolOption 1 "hi";
    terminalColors = mkEnableOption
      "Configure the colors used when opening a :terminal in Neovim";
    italicComments = mkEnableOption "Make comments italic";
    italicKeywords = mkEnableOption "Make keywords italic";
    italicFunctions = mkEnableOption "Make functions italic";
    italicVariables = mkEnableOption "Make variables and identifiers italic";
    transparent =
      mkEnableOption "this to disable setting the background color";
    hideInactiveStatusline = mkEnableOption
      "Enabling this option will hide inactive statuslines and replace them with a thin border";
    transparentSidebar = mkEnableOption
      "Sidebar like windows like NvimTree get a transparent background";
    darkSidebar = mkEnableOption
      "Sidebar like windows like NvimTree get a darker background";
    darkFloat = mkEnableOption
      "Float windows like the lsp diagnostics windows get a darker background";
    lualineBold = mkEnableOption
      "When true, section headers in the lualine theme will be bold";
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
    tokyonight-nvim
  ];
  isColorscheme = true;
}
