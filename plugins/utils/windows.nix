{ pkgs, lib, config, ... }:

with lib;

let

  name = "windows";
  pluginUrl = "https://github.com/anuvyklack/windows.nvim";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
    #
    # autoStart = boolOption true "Enable this pugin at start"
    # todo:
    # animations = boolOption true "Enable animations";
  };

  # pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    windows-nvim
    middleclass
  ];
  extraConfigLua = "require('${name}').setup()"; # ${toLuaObject pluginOptions}";
}
