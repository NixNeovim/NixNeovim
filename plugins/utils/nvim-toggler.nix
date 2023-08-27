{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "nvim-toggler";
  pluginUrl = "https://github.com/nguyenvukhang/nvim-toggler";

  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.custom_options) boolOption typeOption;

  moduleOptions = {
    inverses = typeOption types.attrs { } "Add set of items to toggle like `['vim'] = 'emacs'`";
    removeDefaultKeybinds = boolOption false "Removes the default leader-i keymap";
  };

  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-toggler
  ];
  extraConfigLua = "require('${name}').setup(${toLuaObject pluginOptions})";
  defaultRequire = false;
}
