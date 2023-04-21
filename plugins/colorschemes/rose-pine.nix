{ pkgs, config, lib, ... }:

with lib;

let

  name = "rose-pine";
  pluginUrl = "https://github.com/rose-pine/neovim";

  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions) attrsOption boolOption enumOption;
  cfg = config.programs.nixneovim.colorschemes.${name};

  colors = [ "base" "surface" "overlay" "muted" "subtle" "text" "love" "gold" "rose" "pine" "foam" "iris" "highlight_low" "highlight_med" "highlight_high" ];

  moduleOptions = with helpers; { 
    variant = enumOption [ "auto" "main" "moon" "dawn" ];
    darkVariant = enumOption [ "main" "moon" "dawn" ];
    boldVertSplit = boolOption false "Disable bold vertical split";
    dimNCBackground = boolOption false "Dim the nc background";
    disableBackground = boolOption false "Disable the background";
    disableFloatBackground = boolOption false "Disable the float background";
    disableItalics = boolOption false "Disable italics";

    background = enumOption colors "base" "Set the color of the background";
    backgroundNC = enumOption colors "_experimental_nc" "Sets the color of the nc background";
    panel = enumOption colors "surface" "Set the color of the panel";
    panelNC = enumOption colors "base" "Set the color of the panel nc";
    border = enumOption colors "highlight_med" "Set the color of the border";
    comment = enumOption colors "muted" "Set the color of the comments";
    link = enumOption colors "iris" "Set the color of the links";
    punctuation = enumOption colors "subtle" "Set the color of the punctuation";

    error = enumOption colors "love" "Set the color of errors";
    hint = enumOption colors "iris" "Set the color of hints";
    info = enumOption colors "foam" "Set the color of info";
    warn = enumOption colors "gold" "Set the color of warnings";

    headings = {
      h1 = enumOption colors "iris" "Set the color of heading 1";
      h2 = enumOption colors "foam" "Set the color of heading 2";
      h3 = enumOption colors "rose" "Set the color of heading 3";
      h4 = enumOption colors "gold" "Set the color of heading 4";
      h5 = enumOption colors "pine" "Set the color of heading 5";
      h6 = enumOption colors "foam" "Set the color of heading 6";
    };

    highlightGroups = attrsOption {
      ColorColumn = { bg = "rose"; };
	    CursorLine = { bg = "foam"; blend = 10; };
	    StatusLine = { fg = "love"; bg = "love"; blend = 10; };
    } "Change specific vim highlight groups";
  
  };

  pluginOptions = helpers.convertModuleOptions cfg moduleOptions;

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    rose-pine
  ];
}
