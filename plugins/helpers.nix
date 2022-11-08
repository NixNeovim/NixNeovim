{ lib, config, ... }:

with lib;

rec {

  boolOption = default: description: mkOption {
    type = types.bool;
    description = description;
    default = default;
  };

  intOption = default: description: mkOption {
    type = types.int;
    description = description;
    default = default;
  };

  strOption = default: description: mkOption {
    type = types.str;
    description = description;
    default = default;
  };

  enumOption = enums: default: description:
    mkOption {
      type = types.enum enums;
      inherit description;
      inherit default;
    };

  boolNullOption = description:
    mkOption {
      type = types.nullOr types.bool;
      inherit description;
      default = null;
    };

  intNullOption = description: mkOption {
    type = types.nullOr types.int;
    description = description;
    default = null;
  };

  strNullOption = description: mkOption {
    type = types.nullOr types.str;
    description = description;
    default = null;
  };

  typeOption = type: default: description: mkOption {
    inherit type default description;
  };

  # vim dictionaries are, in theory, compatible with JSON
  toVimDict = args: toJSON
    (lib.filterAttrs (n: v: !isNull v) args);

  # removes empty strings and applies concatStringsSep
  toConfigString = list:
    let
      filtered = filter (str: str != "") list;
    in concatStringsSep "\n" filtered;

  # Black functional magic that converts a bunch of different Nix types to their
  # lua equivalents!
  toLuaObject = args:
    if builtins.isAttrs args then
      let
        filteredArgs = filterAttrs (name: value:
            !isNull value && toLuaObject value != "{}"
          ) args;
      in if hasAttr "__raw" filteredArgs then
        filteredArgs.__raw
      else
        let
          argToLua = name: value:
            if head (stringToCharacters name) == "@" then
              toLuaObject value
            else
              "[${toLuaObject name}] = ${toLuaObject value}";

          listOfValues = mapAttrsToList argToLua filteredArgs;
        in
          if length listOfValues == 0 then
            "{}"
          else
            ''
              {
                ${concatStringsSep ",\n  " listOfValues}
              }''
    else if builtins.isList args then
      "{ ${concatMapStringsSep "," toLuaObject args} }"
    else if builtins.isString args then
      # This should be enough!
      escapeShellArg args
    else if builtins.isBool args then
      "${ boolToString args }"
    else if builtins.isFloat args then
      "${ toString args }"
    else if builtins.isInt args then
      "${ toString args }"
    else if isNull args then
      "nil"
    else "";

  extraConfigTo = extraConfig: { };

  camelToSnake = string:
    with lib;
    stringAsChars (x: if (toUpper x == x) then "_${toLower x}" else x) string;

  toLuaOptions = cfg: moduleOptions:
    let
      attrs = mapAttrs' (k: v: nameValuePair (camelToSnake k) (cfg.${k})) moduleOptions;
      extraAttrs = mapAttrs' (k: v: nameValuePair (camelToSnake k) v) cfg.extraConfig;
    in attrs // extraAttrs;

  # Generates maps for a lua config
  genMaps = mode: maps: let
    normalized = builtins.mapAttrs (key: action:
      if builtins.isString action then
        {
          silent = false;
          expr = false;
          unique = false;
          noremap = true;
          script = false;
          nowait = false;
          action = action;
        }
      else action) maps;
  in builtins.attrValues (builtins.mapAttrs (key: action:
    {
      action = action.action;
      config = lib.filterAttrs (_: v: v) {
        inherit (action) silent expr unique noremap script nowait;
      };
      key = key;
      mode = mode;
    }) normalized);

  # Creates an option with a nullable type that defaults to null.
  mkNullOrOption = type: desc: lib.mkOption {
    type = lib.types.nullOr type;
    default = null;
    description = desc;
  };

  mkPlugin = { config, lib, ... }: {
    name,
    description,
    extraPlugins ? [],
    extraConfigLua ? "",
    extraConfigVim ? "",
    options ? {},
    ...
  }: let
    cfg = config.programs.nixvim.plugins.${name};
    # TODO support nested options!
    moduleOptions = (mapAttrs (k: v: v.option) options);
    # // {
      # extraConfig = mkOption {
      #   type = types.attrs;
      #   default = {};
      #   description = "Place any extra config here as an attibute-set";
      # };
    # };

    globals = mapAttrs' (name: opt: {
      name = opt.global;
      value = if cfg.${name} != null then opt.value cfg.${name} else null;
    }) options;
  in {
    options.programs.nixvim.plugins.${name} = {
      enable = mkEnableOption description;
    } // moduleOptions;

    config.programs.nixvim = mkIf cfg.enable {
      inherit extraPlugins extraConfigVim globals;
      extraConfigLua =
        if stringLength extraConfigLua > 0 then
          "do -- config scope: ${name}\n" + extraConfigLua + "\nend"
        else "";
    };
  };

  # optionSet = extraAttrs: {
  # } // extraAttrs

  mkLuaPlugin = {
    name,
    description,
    extraPlugins,
    extraPackages ? [],
    extraConfigLua ? "",
    extraConfigVim ? "",
    moduleOptions ? {},
    # ...
  }: let
    cfg = config.programs.nixvim.plugins.${name};
  in

  assert assertMsg (length extraPlugins > 0) "Module for '${name}' broken: no plugin specified 'extraPlugins'";

  {
    options.programs.nixvim.plugins.${name} = {
      enable = mkEnableOption description;
      extraConfig = mkOption {
        type = types.attrs;
        default = {};
        description = "Place any extra config here as an attibute-set";
      };
      extraLua = mkOption {
        type = types.str;
        default = "";
        description = "Place any extra lua code here that is loaded after 'extraConfig'";
      };
    } // moduleOptions;

    config.programs.nixvim = mkIf cfg.enable {
      inherit extraPlugins extraPackages extraConfigVim;
      extraConfigLua =
        if stringLength extraConfigLua > 0 then
          ''
          -- config: ${name}
          do
            function setup()
              ${extraConfigLua}
              ${cfg.extraLua}
            end
            success, output = pcall(setup) -- execute 'setup()' and catch any errors
            if not success then
              print(output)
            end
          end
          ''
        else "";
    };
  };

  globalVal = val: if builtins.isBool val then
    (if val == false then 0 else 1)
  else val;

  mkDefaultOpt = { type, global, description ? null, example ? null, default ? null, value ? v: (globalVal v), ... }: {
    option = mkOption {
      type = types.nullOr type;
      default = default;
      description = description;
      example = example;
    };

    inherit value global;
  };

  mkRaw = r: { __raw = r; };
}
