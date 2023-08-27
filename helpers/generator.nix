{ lib, self, super, config }:

let
  inherit (lib)
    mapAttrs'
    types
    mkOption
    nameValuePair;

  inherit (super.converter)
    camelToSnake;

in {

  # Input: config, options attributes from module
  # Output: Attribute set of lua options # todo: clarify
  #
  # converts the module options to lua code and
  # adds the 'extraAttrs'
  convertModuleOptions = cfg: moduleOptions:
    let
      attrs = mapAttrs' (k: v: nameValuePair (camelToSnake k) (cfg.${k})) moduleOptions;
      extraAttrs = mapAttrs' (k: v: nameValuePair (camelToSnake k) v) cfg.extraConfig;
    in
    attrs // extraAttrs;

  # Input: description string
  # These module options are addded to every module
  defaultModuleOptions = description: {
    enable = lib.mkEnableOption description;
    extraConfig = mkOption {
      # this is added to lua in 'convertModuleOptions'
      type = types.attrsOf types.anything;
      default = { };
      description = "Place any extra config here as an attibute-set";
    };
    extraLua = {
      pre = mkOption {
        type = types.str;
        default = "";
        description = "Place any extra lua code here that is loaded before the plugin is loaded";
      };
      post = mkOption {
        type = types.str;
        default = "";
        description = "Place any extra lua code here that is loaded after the plugin is loaded";
      };
    };
  };

  mkLuaPlugin = import ./src/mk_lua_plugin.nix { inherit lib self super config; };

}
