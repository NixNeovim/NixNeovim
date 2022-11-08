{ pkgs, lib, config, ... }:

with lib;

let

  name = "nvim-toggler";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    inverses = typeOption types.attrs {} "Add set of items to toggle like `['vim'] = 'emacs'`";
    removeDefaultKeybinds = boolOption false "Removes the default <leader>i keymap";
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [ 
    nvim-toggler
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
