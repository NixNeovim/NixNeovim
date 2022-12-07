{ pkgs, lib, config, ... }:

with lib;

let

  name = "nvim-dap";
  pluginUrl = "https://github.com/mfussenegger/nvim-dap";

  helpers = import ../../helpers.nix { inherit lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    adapters = import ./adapters.nix { inherit lib pkgs config; };
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-dap
  ];
  extraPackages = with pkgs; [
    lldb
  ];

  extraConfigLua = ''
    local dap = require('dap')
  '';
}
