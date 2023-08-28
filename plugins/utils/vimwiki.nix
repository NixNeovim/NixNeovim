{ pkgs, helpers, config, lib }:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin { inherit config lib; } {
  name = "vimwiki";
  description = "Enable vimwiki.vim";
  extraPackages = [ pkgs.bash ];
  extraPlugins = [ pkgs.vimExtraPlugins.vimwiki ];
}
