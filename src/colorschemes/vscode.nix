{
  pkgs,
  lib,
  helpers,
  config,
}:
with lib; let
  inherit
    (helpers.generator)
    mkLuaPlugin
    ;

  inherit (helpers.custom_options)
    boolOption
    enumOption
    strOption
    ;

  name = "vscode";
  pluginUrl = "https://github.com/Mofiqul/vscode.nvim";

  cfg = config.programs.nixneovim.plugins.${name};

  moduleOptions = with helpers; {
    style = enumOption ["dark" "light"] "dark" "Theme style (light or dark)";
    transparent = boolOption true "Whether to enable transparent background";
    "italic_comments" = boolOption true "Whether to enable italic comments";
    "disable_nvim_tree_bg" = boolOption true "Whether to disable nvim-tree background color";
  };
in
  mkLuaPlugin {
    inherit name moduleOptions pluginUrl;
    extraPlugins = with pkgs.vimExtraPlugins; [
      vscode-nvim
    ];
    defaultRequire = true;
    isColorscheme = true;
    extraConfigLua =
      "require('${name}').load()";
  }
