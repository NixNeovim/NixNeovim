{ pkgs, lib, helpers, config, super }:

let

  inherit (lib)
    mkIf;

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "base16-vim";
  pluginUrl = "https://github.com/chriskempson/base16-vim";

  cfg = config.programs.nixneovim.plugins.${name};

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    enumOption
    intOption
    intOptionStrict;

  themes = super.base16-list;

  moduleOptions = {
    # add module options here
    useTruecolor = intOption 0 "Whether to use truecolor for the colorschemes. If set to false, you'll need to set up base16 in your shell.";
    colorscheme = enumOption themes "default-dark" "The base16 colorscheme to use";

    setUpBar = intOptionStrict 0 "Whether to install the matching plugin for your statusbar. This does nothing as of yet, waiting for upstream support.";
  };

in mkLuaPlugin {

  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    base16-vim
  ];

  defaultRequire = false;

  extraNixNeovimConfig = {
    colorscheme = "base16-${cfg.colorscheme}";

    plugins.airline.theme = mkIf (cfg.setUpBar == 0) "base16";
    plugins.lightline.colorscheme = null;

    options.termguicolors = cfg.useTruecolor;
  };
}
