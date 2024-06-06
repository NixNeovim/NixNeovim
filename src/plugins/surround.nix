{ lib, pkgs, helpers, config }:
let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "surround";
  pluginUrl = "https://github.com/kylechui/nvim-surround";
  pluginName = "nvim-surround";

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptions = {
    # add module options here
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl pluginName;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-surround
  ];
}
