{ pkgs, lib, helpers, super }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "nvim-dap";
  pluginUrl = "https://github.com/mfussenegger/nvim-dap";

  moduleOptions = with helpers; {
    adapters = super.adapters;
  };

in mkLuaPlugin {
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

  defaultRequire = false;
}
