{ lib, pkgs, helpers, config }:
let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (lib)
    toUpper;

  inherit (builtins)
    substring
    stringLength;

  name = "nerdcommenter";
  pluginUrl = "https://github.com/preservim/nerdcommenter";

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
    createDefaultMappings = intOption 1 "Create default mappings";
    spaceDelims = intOption 1 "Add spaces after comment delimiters by default";
    compactSexyComs = intOption 1 "Use compact syntax for prettified multi-line comments";
    defaultAlign = enumOption [ "none" "left" "start" "both" ] "left" "Align line-wise comment delimiters flush left instead of following code indentation";
  };

in mkLuaPlugin {
  inherit name moduleOptionsVim pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nerdcommenter
  ];

  moduleOptionsVimPrefix = "NERD";
  defaultRequire = false;

  # make first char uppercase
  configConverter = x:
    let
      lastChar = stringLength x - 1;
      firstChar = toUpper (substring 0 1 x);
      rest = substring 1 lastChar x;
    in firstChar + rest;
}
