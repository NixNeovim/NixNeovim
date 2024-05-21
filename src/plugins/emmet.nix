{ lib, pkgs, helpers, config }:
let


  inherit (helpers.generator)
     mkLuaPlugin;

  name = "emmet";
  pluginUrl = "https://github.com/emmetio/emmet";

  # only needed when the name of the plugin does not match the
  # name in the 'require("<...>")' call. For example, the plugin 'comment-frame'
  # has to be called with 'require("nvim-comment-frame")'
  # in such a case add 'pluginName = "nvim-comment-frame"'
  # pluginName = ""

  inherit (helpers.custom_options)
    strOption
    enumOption
    attrsOption;

  moduleOptionsVim = {
    # add module options here
    mode = enumOption [ "i" "n" "v" "a" ] "n" "Mode where emmet will enable";
    leaderKey = strOption "<C-Y>" "Set leader key";
    settings = attrsOption {} "Emmet settings";
  };

in mkLuaPlugin {
  inherit name moduleOptionsVim pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    emmet-vim
  ];
  moduleOptionsVimPrefix = "user_emmet_";
  defaultRequire = false;
}
