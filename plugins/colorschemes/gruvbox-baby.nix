{ pkgs, lib, config, ... }:

with lib;

let

  name = "gruvbox-baby";
  pluginUrl = "https://github.com/luisiacc/gruvbox-baby";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.colorschemes.${name};

  inherit (helpers.customOptions)
    attrsOption
    strOption
    enumOption
    boolOption;

  moduleOptions = {
    # add module options here
    backgroundColor = enumOption [ "medium" "dark" ] "medium" "";
    transparentMode = boolOption false "Set background colors to None";
    commentStyle = strOption "italic" "See :h attr-list";
    keywordStyle = strOption "italic" "See :h attr-list";
    stringStyle = strOption "nocombine" "See :h attr-list";
    functionStyle = strOption "bold" "See :h attr-list";
    variableStyle = strOption "NONE" "See :h attr-list";
    highlights = attrsOption {} "Override highlights with your custom highlights";
    colorOverrides = attrsOption {} "Override color palette with your custom colors";
    useOriginalPalette = boolOption false "Use the original gruvbox palette";
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    gruvbox-baby
  ];

  defaultRequire = false;
  isColorscheme = true;

  extraConfigLua = ''
    vim.g.gruvbox_baby_background_color = ${helpers.toLuaObject cfg.backgroundColor}
    vim.g.gruvbox_baby_transparent_mode = ${helpers.toLuaObject cfg.transparentMode}
    vim.g.gruvboy_baby_comment_style = ${helpers.toLuaObject cfg.commentStyle}
    vim.g.gruvboy_baby_keyword_style = ${helpers.toLuaObject cfg.keywordStyle}
    vim.g.gruvboy_baby_string_style = ${helpers.toLuaObject cfg.stringStyle}
    vim.g.gruvboy_baby_function_style = ${helpers.toLuaObject cfg.functionStyle}
    vim.g.gruvboy_baby_variable_style = ${helpers.toLuaObject cfg.variableStyle}
    vim.g.gruvboy_baby_highlights = ${helpers.toLuaObject cfg.highlights}
    vim.g.gruvboy_baby_color_overrides = ${helpers.toLuaObject cfg.colorOverrides}
    vim.g.gruvboy_baby_use_original_palette = ${helpers.toLuaObject cfg.useOriginalPalette}

    vim.cmd[[colorscheme gruvbox-baby]]
  '';
}
