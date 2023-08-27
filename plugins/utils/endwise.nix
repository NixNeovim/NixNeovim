{ pkgs, helpers, ... }@attrs:

let
  inherit (helpers.deprecated)
    mkPlugin;

in mkPlugin attrs {
  name = "endwise";
  description = "Enable vim-endwise";
  extraPlugins = [ pkgs.vimPlugins.vim-endwise ];

  # Yes it's really not configurable
  options = { };
}
