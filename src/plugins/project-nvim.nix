{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "project-nvim";
  pluginUrl = "https://github.com/ahmedkhalf/project.nvim";

  cfg = config.programs.nixneovim.plugins.${name};

  inherit (helpers.custom_options)
    boolOption
    enumOption;


  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;


  moduleOptions = {
    # add module options here
    manualMode = boolOption false "Do not automatically change root directory";
    showHidden = boolOption false "";
    silentChdir = boolOption false "";
    scopeChdir = enumOption [ "global" "tab" "win" ] "global" "Scope for which the directory is changed";

    detectionMethods = mkOption {
      type = types.listOf types.str;
      default = [ "lsp" "pattern" ];
    };

    patterns = mkOption {
      type = types.listOf types.str;
      default = [ ".git" "_darcs" ".hg" ".bzr" ".svn" "Makefile" "package.json" ];
    };

    ignoreLsp = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    excludeDirs = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    datapath = mkOption {
      type = types.str;
      default = "vim.fn.stdpath(\"data\")";
    };

  };

  pluginOptions = flattenModuleOptions cfg moduleOptions;
in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    project-nvim
  ];
  extraConfigLua = "require('project_nvim').setup ${toLuaObject pluginOptions}";
  defaultRequire = false;
}
