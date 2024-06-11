{ pkgs, lib, helpers, config }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "focus";
  pluginUrl = "https://github.com/nvim-focus/focus.nvim";

  # only needed when the name of the name of the module/plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    floatOption
    boolOption;

  moduleOptions = {
    # add module options here
    commands = boolOption true "Create focus commands";
    autoresize = {
      enable = boolOption true "Enabele auto-reizing of splits";
      width = intOption 0 "Force width for focused window";
      height = intOption 0 "Force height for focused window";
      minwidth = intOption 0 "Force minimum width for unfocused window";
      minheight = intOption 0 "Force minimum height for unfocused window";
      heightQuickfix = intOption 10 "Set the height of quickfix panel";
    };
    split = {
      bufnew = boolOption false "Create blank buffer for new split windows";
      tmux = boolOption false "Create tmux splits instead of neovim splits";
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    focus-nvim
  ];
  defaultRequire = true;
}
