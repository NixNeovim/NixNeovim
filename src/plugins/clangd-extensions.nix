{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "clangd-extensions";
  pluginUrl = "https://github.com/p00f/clangd_extensions.nvim";

  inherit (helpers.utils)
    rawLua;

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    rawLuaOption
    boolOption;

  moduleOptions = {
    inlayHints = {
      inline = rawLuaOption "vim.fn.has(\"nvim-0.10\") == 1" "Options other than `highlight' and `priority' only work if `inline' is disabled";
      # Options other than `highlight' and `priority' only work
      # if `inline' is disabled
      # Only show inlay hints for the current line
      onlyCurrentLine = boolOption false "Only show inlay hints for the current line";
      # Event which triggers a refresh of the inlay hints.
      # You can make this { "CursorMoved" } or { "CursorMoved,CursorMovedI" } but
      # not that this may cause  higher CPU usage.
      # This option is only respected when only_current_line and
      # autoSetHints both are true.
      onlyCurrentLineAutocmd = listOption [ "CursorHold" ] "";
      # whether to show parameter hints with the inlay hints or not
      showParameterHints = boolOption true "whether to show parameter hints with the inlay hints or not";
      # prefix for parameter hints
      parameterHintsPrefix = strOption "<- " "prefix for parameter hints";
      # prefix for all the other hints (type, chaining)
      otherHintsPrefix = strOption "=> " "prefix for all the other hints (type, chaining)";
      # whether to align to the length of the longest line in the file
      maxLenAlign = boolOption false "whether to align to the length of the longest line in the file";
      # padding from the left if max_len_align is true
      maxLenAlignPadding = intOption 1 "padding from the left if max_len_align is true";
      # whether to align to the extreme right or not
      rightAlign = boolOption false "whether to align to the extreme right or not";
      # padding from the right if right_align is true
      rightAlignPadding = intOption 7 "padding from the right if right_align is true";
      # The color of the hints
      highlight = strOption "Comment" "The color of the hints";
      # The highlight group priority for extmark
      priority = intOption 100 "The highlight group priority for extmark";
    };
    ast = {
      # These are unicode, should be available in any font
      roleIcons = {
        type = strOption "🄣" "";
        declaration = strOption "🄓" "";
        expression = strOption "🄔" "";
        statement = strOption ";" "";
        specifier = strOption "🄢" "";
        "template argument" = strOption "🆃" "";
      };
      kindIcons = {
        compound = strOption "🄲" "";
        recovery = strOption "🅁" "";
        translationunit = strOption "🅄" "";
        packexpansion = strOption "🄿" "";
        templatetypeparm = strOption "🅃" "";
        templatetemplateparm = strOption "🅃" "";
        templateparamobject = strOption "🅃" "";
      };
      highlights = {
        detail = strOption "Comment" "";
      };
    };
    memoryUsage = {
      border = strOption "none" "";
    };
    symbolInfo = {
      border = strOption "none" "";
    };
  };

in mkLuaPlugin {

# Consider the following additional options:
#
# extraDescription ? "" # description added to the enable function
# extraPackages ? [ ]   # non-plugin packages
# extraConfigLua ? "" # lua config added to the init.vim
# extraConfigVim ? ""   # vim config added to the init.vim
# defaultRequire ? true # add default requrie string?
# extraOptions ? {}     # extra vim options like line numbers, etc
# extraNixNeovimConfig ? {} # extra config applied to 'programs.nixneovim'
# isColorscheme ? false # If enabled, plugin will be added to 'nixneovim.colorschemes' instead of 'nixneovim.plugins'

  inherit name moduleOptions pluginUrl;
  pluginName = "clangd_extensions";
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    clangd-extensions-nvim
  ];
}
