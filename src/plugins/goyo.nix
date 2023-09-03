{ lib, pkgs, helpers, config }:

let

  inherit (helpers.deprecated)
    mkPlugin
    mkDefaultOpt;

  inherit (lib)
    types;

in mkPlugin { inherit config lib; } {
  name = "goyo";
  description = "Enable goyo.vim";
  extraPlugins = [ pkgs.vimPlugins.goyo-vim ];

  options = {
    width = mkDefaultOpt {
      description = "Width";
      global = "goyo_width";
      type = types.int;
    };

    height = mkDefaultOpt {
      description = "Height";
      global = "goyo_height";
      type = types.int;
    };

    showLineNumbers = mkDefaultOpt {
      description = "Show line numbers when in Goyo mode";
      global = "goyo_linenr";
      type = types.bool;
    };
  };
}
