{ pkgs, lib, helpers, config }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  inherit (helpers.custom_options)
    boolOption
    attrsOption;

  name = "nvim-toggler";
  pluginUrl = "https://github.com/nguyenvukhang/nvim-toggler";

  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = {
    inverses = attrsOption { } "Add set of items to toggle like `['vim'] = 'emacs'`";
    removeDefaultKeybinds = boolOption false "Removes the default leader-i keymap";
  };

  pluginOptions = flattenModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-toggler
  ];
  extraConfigLua = "require('${name}').setup(${toLuaObject pluginOptions})";
  defaultRequire = false;
}
