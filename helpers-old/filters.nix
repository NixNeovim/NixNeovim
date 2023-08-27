{ lib }:

{ cfg }:

let

  inherit (lib)
    attrNames
    concatStringsSep
    filter
    filterAttrs
    flatten
    mapAttrs
    mapAttrs'
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    stringLength
    types;

  # filters activated options from a set
  activated = options: filterAttrs (name: attrs: cfg.${name}.enable) options;
in {

  inherit activated;

  ##############################################################################
  # helper functions for plugins with sub-plugins like cmp, lsp, telescope, etc.

  # returns a list of the names of all activated options
  activatedNames = options: attrNames (activated options);

  activatedPackages = options:
    flatten (mapAttrsToList (name: attrs: attrs.packages) (activated options));

  activatedLuaNames = options:
    flatten (mapAttrsToList (name: attrs: attrs.luaName) (activated options));

  activatedPlugins = options:
    flatten (mapAttrsToList (name: attrs: attrs.plugins) (activated options));

  activatedConfig = options:
    mapAttrsToList (name: attrs: attrs.extraConfig) (activated options);

}
