{ lib, pkgs, config, ... }@attrs:
let
  helpers = import ../../helper { inherit pkgs lib config; };
in
with helpers; with lib;
mkPlugin attrs {
  name = "vimwiki";
  description = "Enable vimwiki.vim";
  extraPackages = [ pkgs.bash ];
  extraPlugins = [ pkgs.vimExtraPlugins.vimwiki ];
}
