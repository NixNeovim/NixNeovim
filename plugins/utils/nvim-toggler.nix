{ pkgs, lib, config, ... }:

with lib;

let

  name = "nvim-toggler";
  pluginUrl = "https://github.com/nguyenvukhang/nvim-toggler";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};
  inherit (helpers.customOptions) boolOption typeOption;

  moduleOptions = {
    inverses = typeOption types.attrs { } "Add set of items to toggle like `['vim'] = 'emacs'`";
    removeDefaultKeybinds = boolOption false "Removes the default leader-i keymap";
  };

  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-toggler
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
