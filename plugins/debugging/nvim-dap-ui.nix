{ pkgs, lib, config, ... }:

with lib;

let

  name = "nvim-dap-ui";
  pluginUrl = "https://github.com/rcarriga/nvim-dap-ui";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    # add module options here
  };
  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    nvim-dap-ui
  ];
  extraConfigLua = "require('dapui').setup ${toLuaObject pluginOptions}";
}
