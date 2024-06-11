{ pkgs, lib, helpers, config }:

let

  inherit (helpers.generator)
     mkLuaPlugin;

  name = "gruvbox-nvim";
  pluginUrl = "https://github.com/ellisonleao/gruvbox.nvim";

  inherit (helpers.custom_options)
    enumOption
    boolOption;

  moduleOptions = {
    # add module options here
    italics = {
      strings = boolOption true "";
      emphasis = boolOption true "";
      comments = boolOption true "";
      operators = boolOption true "";
      folds = boolOption true "";
    };
    bold = boolOption true "bold";
    underline = boolOption true "underlined text";
    undercurl = boolOption true "undercurled text";
    contrastDark = enumOption [ "soft" "" "hard" ] "" "Contrast for the dark mode";

    invertSelection = boolOption false "Invert the select text";
    invertSigns = boolOption false "Invert GitGutter and Syntastic signs";

    invertIndentGuides = boolOption false "Invert indent guides";
    invertTabline = boolOption false "Invert tabline highlights";
    transparentMode = boolOption false "Transparent background";
    terminalColor = boolOption true "true color support";
    strikethrough = boolOption true "";
    constrast = boolOption true "";
    dimInactive = boolOption false "";
  };

in mkLuaPlugin {

  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    gruvbox-nvim
  ];

  isColorscheme = true;
  extraConfigLua = ''
    vim.cmd[[ colorscheme gruvbox ]]
  '';
}
