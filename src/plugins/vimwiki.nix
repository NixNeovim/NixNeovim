{ pkgs, lib, helpers, ... }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "vimwiki";
  pluginUrl = "https://github.com/vimwiki/vimwiki";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    attrsOption
    intOption
    boolOption;


  ext2syntaxDefault = {
    ".md" = "markdown";
    ".mdwn" = "markdown";
    ".mkdn" = "markdown";
    ".mdown" = "markdown";
    ".markdown" = "markdown";
    ".mw" = "media";
  };

  moduleOptionsVim = {
    # add module options here
    list = listOption [] "Use this to change the syntex to either Markdown or MediaWiki.";
    globalExt = intOption 1 "Set this to treat all markdown files in your system as part of vimwiki";
    ext2syntax = attrsOption ext2syntaxDefault "A many-to-one mapping between file extensions and syntaxes whose purpose is to register the extensions with Vimwiki.";
  };

in mkLuaPlugin {
  inherit name moduleOptionsVim pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    vimwiki
  ];
  # extraPackages = [ pkgs.bash ];
  defaultRequire = false;
}
