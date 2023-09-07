{ pkgs, helpers, config, lib }:

let
  inherit (helpers.deprecated)
    mkPlugin;

in mkPlugin { inherit config lib; } {
  name = "endwise";
  description = "Enable vim-endwise";
  extraPlugins = [ pkgs.vimPlugins.vim-endwise ];

  # Yes it's really not configurable
  options = { };
}
