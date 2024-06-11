{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "nord";
  pluginUrl = "https://github.com/shaunsingh/nord.nvim";

  cfg = config.programs.nixneovim.colorschemes.nord;

  moduleOptions = {

    contrast = mkEnableOption
      "Make sidebars and popup menus like nvim-tree and telescope have a different background";

    borders = mkEnableOption
      "Enable the border between verticaly split windows visable";

    disable_background = mkEnableOption
      "Disable the setting of background color so that NeoVim can use your terminal background";

    cursorline_transparent = mkEnableOption
      "Set the cursorline transparent/visible";

    enable_sidebar_background = mkEnableOption
      "Re-enables the background of the sidebar if you disabled the background of everything";

    italic = mkOption {
      description = "enables/disables italics";
      type = types.nullOr types.bool;
      default = null;
    };
  };

in helpers.generator.mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    shaunsingh-nord-nvim
  ];
  isColorscheme = true;
  extraConfigLua = ''
    vim.cmd[[ colorscheme nord ]]
  '';

  extraOptions = {
    nord_contrast = mkIf cfg.contrast 1;
    nord_borders = mkIf cfg.borders 1;
    nord_disable_background = mkIf cfg.disable_background 1;
    nord_cursoline_transparent = mkIf cfg.cursorline_transparent 1;
    nord_enable_sidebar_background = mkIf cfg.enable_sidebar_background 1;
    nord_italic = mkIf (cfg.italic != null) cfg.italic;
  };
}
