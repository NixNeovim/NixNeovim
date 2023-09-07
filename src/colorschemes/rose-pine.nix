{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "rose-pine";
  pluginUrl = "https://github.com/rose-pine/neovim";


  inherit (helpers.custom_options)
    attrsOption
    strOption
    enumOption
    boolOption;

  colors = [ "base" "surface" "overlay" "muted" "subtle" "text" "love" "gold" "rose" "pine" "foam" "iris" "highlight_low" "highlight_med" "highlight_high" "_experimental_nc" ];

  moduleOptions = {
    variant = enumOption [ "auto" "main" "moon" "dawn" ] "auto" "";
    dark_variant = enumOption [ "main" "moon" "dawn" ] "main" "";
    bold_vert_split = boolOption false "Disable bold vertical split";
    dim_nc_background = boolOption false "Dim the nc background";
    disable_background = boolOption false "Disable the background";
    disable_float_background = boolOption false "Disable the float background";
    disable_italics = boolOption false "Disable italics";

    groups = {
      background = enumOption colors "base" "Set the color of the background";
      background_nc = enumOption colors "_experimental_nc" "Sets the color of the nc background";
      panel = enumOption colors "surface" "Set the color of the panel";
      panel_nc = enumOption colors "base" "Set the color of the panel nc";
      border = enumOption colors "highlight_med" "Set the color of the border";
      comment = enumOption colors "muted" "Set the color of the comments";
      link = enumOption colors "iris" "Set the color of the links";
      punctuation = enumOption colors "subtle" "Set the color of the punctuation";

      error = enumOption colors "love" "Set the color of errors";
      hint = enumOption colors "iris" "Set the color of hints";
      info = enumOption colors "foam" "Set the color of info";
      warn = enumOption colors "gold" "Set the color of warnings";
    };

    headings = {
      h1 = enumOption colors "iris" "Set the color of heading 1";
      h2 = enumOption colors "foam" "Set the color of heading 2";
      h3 = enumOption colors "rose" "Set the color of heading 3";
      h4 = enumOption colors "gold" "Set the color of heading 4";
      h5 = enumOption colors "pine" "Set the color of heading 5";
      h6 = enumOption colors "foam" "Set the color of heading 6";
    };

    highlight_groups = attrsOption {} "Change specific vim highlight groups";

  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    rose-pine
  ];

  defaultRequire = true;
  isColorscheme = true;

  extraConfigLua = "vim.cmd('colorscheme rose-pine')";
}
