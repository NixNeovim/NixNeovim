{ pkgs, helpers, ... }@attrs:

let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin attrs {
  name = "tagbar";
  description = "Enable tagbar";
  extraPlugins = with pkgs.vimExtraPlugins; [
    tagbar
  ];
}
