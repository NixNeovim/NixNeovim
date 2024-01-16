{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    flattenModuleOptions
    toLuaObject;

  name = "catppuccin";
  pluginUrl = "https://github.com/catppuccin/nvim";

  cfg = config.programs.nixneovim.colorschemes.${name};

  inherit (helpers.custom_options)
    boolOption
    enumOption
    floatOption
    listOption
    strOption;

  moduleOptions = with helpers; {
    flavour = enumOption [ "latte" "frappe" "macchiato" "mocha" ] "mocha" "Set flavour of Catppuccin theme.";
    background = {
      light = strOption "latte" "";
      dark = strOption "mocha" "";
    };
    transparentBackground = boolOption false "Disable setting the background color.";
    showEndOfBuffer = boolOption false "Show '~' character after the end of buffers.";
    termColors = boolOption false "Set terminal colors.";
    dimInactive = {
      enabled = boolOption false "Dim background color of active window.";
      shade = strOption "dark" "Set shade of dim color.";
      percentage = floatOption 0.15 "Percentage of the shade to apply to inactive window.";
    };
    noItalic = boolOption false "Force no italic.";
    noBold = boolOption false "Force no bold.";
    noUnderline = boolOption false "Force no underline.";
    style = {
      comments = listOption [
        "italic"
      ] "Change the style of comments.";
      conditionals = listOption [
        "italic"
      ] "";
      loops = {};
      functions = {};
      keywords = {};
      strings = {};
      variables = {};
      numbers = {};
      booleans = {};
      properties = {};
      types = {};
      operators = {};
    };
    colorOverrides = {};
    customHighlights = {};
    integrations = {
      cmp = boolOption true "";
      gitsigns = boolOption true "";
      nvimtree = boolOption true "";
      treesitter = boolOption true "";
      notify = boolOption false "";
      mini = {
        enabled = boolOption true "";
        indentscopeColor = strOption "" "";
      };
    };
  };

  pluginOptions = flattenModuleOptions cfg moduleOptions;

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    catppuccin
  ];

  extraConfigLua = ''
    vim.cmd[[colorscheme catppuccin]]
  '';
  
  isColorscheme = true;
}
