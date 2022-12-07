{ pkgs, lib, config, ... }:

with lib;

let

  name = "project-nvim";
  pluginUrl = "https://github.com/ahmedkhalf/project.nvim";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
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
      type = types.either types.str helpers.rawType;
      default = "vim.fn.stdpath(\"data\")";
    };

  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;
in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    project-nvim
  ];
  extraConfigLua = "require('project_nvim').setup ${toLuaObject pluginOptions}";
}
