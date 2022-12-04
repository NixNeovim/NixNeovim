{ pkgs, lib, config, ... }:

with lib;

let

  name = "scrollbar";
  pluginUrl = "https://github.com/petertriho/nvim-scrollbar";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    # nvim-treesitter
    nvim-scrollbar
  ];
  extraPackages = with pkgs; [
    # add neovim plugin here
    # tree-sitter
  ];
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
