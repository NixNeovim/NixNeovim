{ pkgs, lib, config, ... }:

with lib;

let

  name = "colorizer";
  pluginUrl = "https://github.com/NvChad/nvim-colorizer.lua";

  helpers = import ../helpers.nix { inherit lib config; };

  moduleOptions = with helpers; {
    # add module options here
    filtypes = listOption [ "*" ] "";
    userDefaultOptions = {
      RGB = boolOption true "#RGB hex codes";
      RRGGBB = boolOption true "#RRGGBB hex codes";
      names = boolOption true "\"Name\" codes like Blue or blue";
      RRGGBBAA = boolOption false "#RRGGBBAA hex codes";
      AARRGGBB = boolOption false "0xAARRGGBB hex codes";
      rgbFn = boolOption false "CSS rgb() and rgba() functions";
      hlsFn = boolOption false "CSS hsl() and hsla() functions";
      css = boolOption false "Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB";
      cssFn = boolOption false "Enable all CSS *functions*: rgb_fn, hsl_fn";
      mode = enumOption [ "background" "foreground" "virtualtext" ] "background" "How to display the color";
      tailwind = boolOption false "Enable tailwind colors";
      sass = {
        enable = boolOption false "";
        parsers = listOption [ "css" ] "";
      };
      virtualtext = strOption "■" "";
    };
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-colorizer-lua
  ];
}
