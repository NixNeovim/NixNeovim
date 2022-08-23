{ pkgs, lib, config, ... }:

with lib;

let

  name = "luasnip";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    enableAutosnippets = boolNullOption "";
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [ 
    # add neovim plugin here
    # nvim-treesitter
    LuaSnip
  ];
  extraPackages = with pkgs; [ 
    # add neovim plugin here
    # tree-sitter
  ];
  extraConfigLua = "require('${name}').config.setup ${toLuaObject pluginOptions}";
}
