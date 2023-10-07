{ lib, self, super, config }:

let
  inherit (lib)
    types
    mkOption;


in {

  # Input: description string
  # These module options are addded to every module
  defaultModuleOptions = description: {
    enable = lib.mkEnableOption description;
    extraConfig = mkOption {
      # this is added to lua in 'flattenModuleOptions'
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
