{ lib, config, cfg-plugin ? {}, ... }:

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

  attrsOption = default: description: mkOption {
    type = types.attrsOf types.anything;
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
        nonNullArgs = filterAttrs (name: value:
            !isNull value # && toLuaObject value != "{}"
          ) args;
      in if hasAttr "__raw" nonNullArgs then
        nonNullArgs.__raw
      else
        let
          argToLua = name: value:
            if head (stringToCharacters name) == "@" then
              toLuaObject value
            else
              "[${toLuaObject name}] = ${toLuaObject value}";

          listOfValues = mapAttrsToList argToLua nonNullArgs;
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

  # helper function to create a lua based plugin # TODO: make usable with non-lua plugins
  mkLuaPlugin = {
    name,
    description,
    extraPlugins,
    extraPackages ? [],
    extraConfigLua ? null,
    extraConfigVim ? "",
    moduleOptions ? {},
    addRequire ? true,
  }: let
    errorString = "Module for ${name} broken";

    cfg = config.programs.nixvim.plugins.${name};

    pluginOptions = toLuaOptions cfg moduleOptions;

    # add default require string to load plugin
    luaConfig = optionalString addRequire (if (extraConfigLua == null) then
      "require('${name}').setup ${toLuaObject pluginOptions}"
    else extraConfigLua);

    # These module options are addded to every module
    generalModuleOptions = {
      enable = mkEnableOption description;
      extraConfig = mkOption { # this is added to lua in 'toLuaOptions'
        type = types.attrsOf types.anything;
        default = {};
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
  in

  # assert assertMsg (extraPlugins != []) "${errorString}: no plugin specified 'extraPlugins'"; # FIX: this somehow results in infinite recursion
  assert assertMsg (stringLength name > 0) " ${errorString}: 'name' is empty";
  assert assertMsg (!hasAttr "enable" moduleOptions) "${errorString}: Please remove the 'enable' options. This is added by 'mkLuaPLugin' automatically";

  {
    options.programs.nixvim.plugins.${name} = generalModuleOptions // moduleOptions;

    config.programs.nixvim = mkIf cfg.enable {
      inherit extraPlugins extraPackages extraConfigVim;
      extraConfigLua = ''
        -- config for plugin: ${name}
        do
          function setup()
            ${cfg.extraLua.pre}
            ${luaConfig}
            ${cfg.extraLua.post}
          end
          success, output = pcall(setup) -- execute 'setup()' and catch any errors
          if not success then
            print(output)
          end
        end
        '';
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

  ##############################################################################
  # helper functions for plugins with sub-plugins like cmp, lsp, telescope, etc.

  # filters activated options from a set
  activated = options: filterAttrs (name: attrs: cfg-plugin.${name}.enable) options;

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
