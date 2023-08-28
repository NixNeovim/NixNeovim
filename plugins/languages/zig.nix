{ lib, pkgs, helpers, config }:
let
  inherit (helpers.deprecated)
      mkDefaultOpt
      mkPlugin;

  inherit (lib)
    types;

in mkPlugin { inherit lib config; } {
  name = "zig";
  description = "Enable zig";
  extraPlugins = [ pkgs.vimPlugins.zig-vim ];

  # Possibly add option to disable Treesitter highlighting if this is installed
  options = {
    formatOnSave = mkDefaultOpt {
      type = types.bool;
      global = "zig_fmt_autosave";
      description = "Run zig fmt on save";
    };
  };
}
