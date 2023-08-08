{ pkgs, lib, config, ... }:

with lib;

let

  name = "kanagawa";
  pluginUrl = "https://github.com/rebelot/kanagawa.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.colorschemes.${name};

  inherit (helpers.customOptions)
    attrsOption
    strOption
    enumOption
    boolOption;

  moduleOptions = {
    # add module options here
    compile = boolOption false "";
    # enable compiling the colorscheme
    undercurl = boolOption true "";
    # enable undercurls
    commentstyle = { italic = boolOption true ""; };
    functionstyle = { };
    keywordstyle = { italic = boolOption true ""; };
    statementstyle = { bold = boolOption true ""; };
    typestyle = { };
    transparent = boolOption false "";
    diminactive = boolOption false "";
    terminalcolors = boolOption true "";
    # define vim.g.terminal_color_{0,17}
    colors = {
      # add/modify theme and palette colors
      palette = { };
      theme = {
        wave = { };
        lotus = { };
        dragon = { };
        all = { };
      };
    };
    theme = strOption "wave" "";
    # Load "wave" theme when 'background' option is not set
    background = {
      # map the value of 'background' option to a theme
      dark = strOption "wave" "";
      # try "dragon" !
      light = strOption "lotus" "";
    };
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    kanagawa-nvim
  ];

  defaultRequire = true;
  isColorscheme = true;

  extraConfigLua = ''
    vim.cmd[[colorscheme kanagawa]]
  '';
}
