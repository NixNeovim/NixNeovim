{ pkgs, lib, helpers, config }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    toVimOptions;

  name = "magma";
  pluginUrl = "https://github.com/dccsillag/magma-nvim";

  inherit (helpers.custom_options)
    strOption
    rawLuaOption
    enumOption
    boolOption;

  moduleOptions = {

    imageProvider = enumOption ["none" "ueberzug" "kitty"] "none" ''
        This configures how to display images. The following options are available:
          - "none" -- don't show images.
          - "ueberzug" -- use Ueberzug to display images.
          - "kitty" -- use the Kitty protocol to display images.
      '';

      automaticallyOpenOutput = boolOption true ''
          If this is true, then whenever you have an active cell its output window will be
          automatically shown.

          If this is false, then the output window will only be automatically shown when you've just
          evaluated the code.
          So, if you take your cursor out of the cell, and then come back, the output window won't
          be opened (but the cell will be highlighted).
          This means that there will be nothing covering your code.
          You can then open the output window at will using `:MagmaShowOutput`.
        '';

      wrapOutput = boolOption true ''
          If this is true, then text output in the output window will be wrapped
          (akin to `set wrap`).
        '';

      outputWindowBorders = boolOption true ''
          If this is true, then the output window will have rounded borders.
          If it is false, it will have no borders.
        '';

      cellHighlightGroup = strOption "CursorLine" ''
          The highlight group to be used for highlighting cells.
        '';

      savePath = rawLuaOption "' '" ''
          Where to save/load with :MagmaSave and :MagmaLoad (with no parameters).
          The generated file is placed in this directory, with the filename itself being the
          buffer's name, with % replaced by %% and \/ replaced by %, and postfixed with the extension
          .json.
        '';

      showMimetypeDebug = boolOption false ''
          If this is true, then before any non-iostream output chunk, Magma shows the mimetypes it
          received for it.
          This is meant for debugging and adding new mimetypes.
        '';
  };


  cfg = config.programs.nixneovim.plugins.${name};

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
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    magma-nvim
  ];

  defaultRequire = false;
  extraConfigLua = ''
    ${toVimOptions cfg "magma_" moduleOptions}
  '';

}
