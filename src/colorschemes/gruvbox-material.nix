{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "gruvbox-material";
  pluginUrl = "https://github.com/sainnhe/gruvbox-material";

  cfg = config.programs.nixneovim.colorschemes.${name};
  inherit (helpers.custom_options)
    enumOption
    intOption
    boolOptionStrict;

  inherit (helpers.converter)
    toLuaObject
    boolToLuaInt;

  moduleOptions = {
    # add module options here
    background = enumOption [ "hard" "medium" "soft" ] "medium" "The background contrast used in this color scheme";
    foreground = enumOption [ "material" "mix" "original" ] "material" ''
        The foreground color palette used in this color scheme.

        - `material`: Carefully designed to have a soft contrast.
        - `mix`: Color palette obtained by calculating the mean of the other two.
        - `original`: The color palette used in the original gruvbox.
      '';
    disableItalicComment = boolOptionStrict false "By default, italic is enabled in `Comment`. To disable italic in `Comment`, set this option to `1`.";
    enableBold = boolOptionStrict false "To enable bold in function name just like the original gruvbox, set this option to `1`. ";
    enableItalic = boolOptionStrict false "To enable italic in this color scheme, set this option to `1`.";
    transparentBackground = intOption 0 "If you want more ui components to be transparent (for example, status line background), set this option to `2`.";
    dimInactiveWindows = boolOptionStrict false "Dim inactive windows. Only works in neovim currently.";
    betterPerformance = boolOptionStrict false ''
        The loading time of this color scheme is very long because too many file types
        and plugins are optimized. This feature allows you to load part of the code on
        demand by placing them in the `after/syntax` directory.

        Enabling this option will reduce loading time by approximately 50%.
      '';
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    gruvbox-material
  ];

  defaultRequire = false;
  isColorscheme = true;

  extraConfigLua = ''
    vim.g.gruvbox_material_background = ${toLuaObject cfg.background}
    vim.g.gruvbox_material_foreground = ${toLuaObject cfg.foreground}
    vim.g.gruvbox_material_disable_italic_comment = ${boolToLuaInt cfg.disableItalicComment}
    vim.g.gruvbox_material_enable_bold = ${boolToLuaInt cfg.enableBold}
    vim.g.gruvbox_material_enable_italic = ${boolToLuaInt cfg.enableItalic}
    vim.g.gruvbox_material_transparent_background = ${toLuaObject cfg.transparentBackground}
    vim.g.gruvbox_material_dim_inactive_windows = ${boolToLuaInt cfg.dimInactiveWindows}
    vim.g.gruvbox_material_better_performance = ${boolToLuaInt cfg.betterPerformance}

    vim.cmd[[colorscheme gruvbox-material]]
  '';
}
