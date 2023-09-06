{ lib, usePluginDefaults, super }:

let

  # This ist a list of custom 'mkOption' functions that aim to
  # simplify the option creation for plugins.
  # They always have a default value, however, the default is only applied
  # when usePluginDefaults is false. Then the option will not be written to
  # the init.lua and the respective plugin defaults will be respected.
  #
  # The ...Strict ignore the 'usePluginDefaults' setting and always have a
  # defined value. This is used for some plugin-module options
  # that are processed in other parts of the plugin-module.
  # Otherwise the respective 'if' or 'mkIf' statements could fail,
  # because they cannot handle 'null' arguments

  inherit (lib)
    mkOption
    mkOptionType
    types;

  inherit (super.utils)
    isRawLua;

  usePlugDef = default:
    if usePluginDefaults then
      null
    else
      default;

  myTypes = with types; {
    bool = nullOr bool;
    int = nullOr int;
    str = nullOr str;
    list = nullOr (listOf anything);
    attrs = nullOr (attrsOf anything);
    enum = enums: nullOr (enum enums);
  };

  rawLuaType = mkOptionType {
    name = "rawLuaType";
    check = value: isRawLua value;
  };

in with myTypes; {
  boolOption = default: description:
    mkOption {
      type = bool;
      default = usePlugDef default;
      inherit description;
    };

  # This is a version of boolOption that does always have a fixed value
  boolOptionStrict = default: description:
    mkOption {
      type = bool;
      default = default;
      inherit description;
    };

  intOption = default: description:
    mkOption {
      type = int;
      default = usePlugDef default;
      inherit description;
    };

  strOption = default: description:
    mkOption {
      type = str;
      default = usePlugDef default;
      inherit description;
    };

  rawLuaOption = default: description:
    mkOption {
      type = rawLuaType;
      default = usePlugDef default;
      inherit description;
    };

  attrsOption = default: description:
    mkOption {
      type = attrs;
      default = usePlugDef default;
      inherit description;
    };

  listOption = default: description:
    mkOption {
      type = list;
      default = usePlugDef default;
      inherit description;
    };

  enumOption = enums: default: description:
    mkOption {
      type = enum enums;
      default = usePlugDef default;
      inherit description;
    };

  boolNullOption = description:
    mkOption {
      type = types.nullOr types.bool;
      default = null;
      inherit description;
    };

  intNullOption = description:
    mkOption {
      type = types.nullOr types.int;
      default = null;
      inherit description;
    };

  strNullOption = description:
    mkOption {
      type = types.nullOr types.str;
      default = null;
      inherit description;
    };

  typeOption = type: default: description:
    mkOption {
      inherit type description;
      default = usePlugDef default;
    };

}
