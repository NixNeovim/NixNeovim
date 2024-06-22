{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "rose-pine";
  pluginUrl = "https://github.com/rose-pine/neovim";


  inherit (helpers.custom_options)
    attrsOption
    enumOption
    boolOption;

  colors = [ "base" "surface" "overlay" "muted" "subtle" "text" "love" "gold" "rose" "pine" "foam" "iris" "highlight_low" "highlight_med" "highlight_high" ];

  moduleOptions = {
    variant = enumOption [ "auto" "main" "moon" "dawn" ] "auto" "";
    dark_variant = enumOption [ "main" "moon" "dawn" ] "main" "";
    dim_inactive_windows = boolOption false;
    extend_background_behind_borders = boolOption true;

    enable = {
      terminal = boolOption true;
      legacy_highlights = boolOption true;
      migrations = boolOption true;
    };

    styles = {
      bold = boolOption true "Enable bold";
      italic = boolOption true "Enable italics";
      transparency = boolOption false "Enable transparency";
    };

    groups = {
      border = enumOption colors "muted" "Set the color of borders";
      link = enumOption colors "iris" "Set the color of links";
      panel = enumOption colors "surface" "Set the color of panels";

      error = enumOption colors "love" "Set the color of errors";
      hint = enumOption colors "iris" "Set the color of hints";
      info = enumOption colors "foam" "Set the color of info";
      note = enumOption colors "pine" "Set the color of note";
      todo = enumOption colors "rose" "Set the color of todo";
      warn = enumOption colors "gold" "Set the color of warnings";

      git_add = enumOption colors "foam" "Set the color of Git add";        
      git_change = enumOption colors "rose" "Set the color of Git change";
      git_delete = enumOption colors "love" "Set the color of Git delete";
      git_dirty = enumOption colors "rose" "Set the color of Git dirty";
      git_ignore = enumOption colors "muted" "Set the color of Git ignore";
      git_merge = enumOption colors "iris" "Set the color of Git merge";
      git_rename = enumOption colors "pine" "Set the color of Git rename";
      git_stage = enumOption colors "iris" "Set the color of Git stage";
      git_text = enumOption colors "rose" "Set the color of Git text";
      git_untracked = enumOption colors "subtle" "Set the color of Git untracked";

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
