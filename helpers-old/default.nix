{ pkgs, lib, config, ... }:

let

  inherit (lib)
    concatStringsSep
    filter
    filterAttrs
    mapAttrs
    mapAttrs'
    mkEnableOption
    mkIf
    mkOption
    stringLength
    types;

  globalVal = val:
    if builtins.isBool val then
      (if val == false then 0 else 1)
    else val;

  customOptions = import ./custom_options.nix { inherit mkOption types config; };

  toLua = import ./to_lua { inherit lib customOptions config; };

in {

  # module to handle key mappings
  keymappings = pkgs.callPackage ./keymappings.nix {
    inherit customOptions;
    inherit (toLua) toLuaObject;
  };

  # module to handle augroups
  augroups = import ./augroups.nix {inherit lib customOptions; inherit (toLua) toLuaObject;};

  inherit (toLua)
    toLuaObject
    toLuaObject'
    convertModuleOptions
    camelToSnake
    boolToInt
    boolToInt';
  inherit customOptions toLua;
  inherit (toLua)
    mkLuaPlugin;

  filters = import ./filters.nix { inherit lib; };

  # vim dictionaries are, in theory, compatible with JSON
  toVimDict = args: builtins.toJSON
    (lib.filterAttrs (n: v: !isNull v) args);

  # remove the enable key from a attribute set
  removeEnable = attrs:
    filterAttrs (n: _: n != "enable") attrs;

  # removes empty strings and applies concatStringsSep
  toConfigString = list:
    let
      filtered = filter (str: str != "") list;
    in
    concatStringsSep "\n" filtered;

  mkNullOrOption = type: desc: lib.mkOption {
    type = lib.types.nullOr type;
    default = null;
    description = desc;
  };

  # input: attribute set with camelCase keys
  # output: attribute set with snake_case keys
  keyToSnake = attrs:
    mapAttrs'
      (key: value: { name = toLua.camelToSnake key; value = value; })
      attrs;

  # WARN: deprecated: use mkLuaPlugin
  mkPlugin = { config, lib, ... }:
    { name
      , description
      , extraPlugins ? [ ]
      , extraConfigLua ? ""
      , extraConfigVim ? ""
      , options ? { }
      , ...
    }:
    let
      cfg = config.programs.nixneovim.plugins.${name};
      # TODO support nested options!
      moduleOptions = (mapAttrs (k: v: v.option) options);
      # // {
      # extraConfig = mkOption {
      #   type = types.attrs;
      #   default = {};
      #   description = "Place any extra config here as an attibute-set";
      # };
      # };

      globals = mapAttrs'
        (name: opt: {
          name = opt.global;
          value = if cfg.${name} != null then opt.value cfg.${name} else null;
        })
        options;
    in
    {
      options.programs.nixneovim.plugins.${name} = {
        enable = mkEnableOption description;
      } // moduleOptions;

      config.programs.nixneovim = mkIf cfg.enable {
        inherit extraPlugins extraConfigVim globals;
        extraConfigLua =
          if stringLength extraConfigLua > 0 then
            "do -- config scope: ${name}\n" + extraConfigLua + "\nend"
          else "";
      };
    };

  mkDefaultOpt = { type, global, description ? null, example ? null, default ? null, value ? v: (globalVal v), ... }: {
    option = mkOption {
      type = types.nullOr type;
      default = default;
      description = description;
      example = example;
    };

    inherit value global;
  };

  # NOTE: deprecated in favor of rawLua in lib.nix
  mkRaw = r: { __raw = r; };

}
