{ pkgs, helpers, config, lib }:

let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin { inherit lib config; } {
  name = "tagbar";
  description = "Enable tagbar";
  extraPlugins = with pkgs.vimExtraPlugins; [
    tagbar
  ];
}
