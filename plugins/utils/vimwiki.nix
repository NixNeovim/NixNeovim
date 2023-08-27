{ pkgs, helpers, ... }@attrs:
let
  inherit (helpers.deprecated)
      mkPlugin;
in mkPlugin attrs {
  name = "vimwiki";
  description = "Enable vimwiki.vim";
  extraPackages = [ pkgs.bash ];
  extraPlugins = [ pkgs.vimExtraPlugins.vimwiki ];
}
