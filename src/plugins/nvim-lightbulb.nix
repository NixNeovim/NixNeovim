{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "nvim-lightbulb";
  pluginUrl = "https://github.com/kosayoda/nvim-lightbulb";

  inherit (helpers.custom_options)
    boolOption
    strOption
    attrsOption
    intOption
    enumOption;

  moduleOptions = {
    # add module options here
    ignore = attrsOption {} "LSP client names to ignore";
    sign = {
      enable = boolOption true "";
      priority = intOption 10 "Priority of the gutter sign";
    };
    virtual_text = {
        enabled = boolOption false "";
        text = strOption "💡" "Text to show at virtual text";
        hlMode = enumOption [ "replace" "combine" "blend" ] "replace" "highlight mode to use for virtual text (replace, combine, blend), see :help nvim_buf_set_extmark() for reference";
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-lightbulb
  ];
}
