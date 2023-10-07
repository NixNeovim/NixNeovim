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
    escapeXML
    types;

  inherit (super.utils)
    rawLua
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
    float = nullOr float;
    list = nullOr (listOf anything);
    attrs = nullOr (attrsOf anything);
    enum = enums: nullOr (enum enums);
  };

  rawLuaType = mkOptionType {
    name = "rawLuaType";
    check = value:
      if !(isRawLua value) then
        lib.warn "Your input ${value} does not seem to be lua code. Did you use the 'nixneovim.lib.rawLua' function?"
        false
      else
        true;


  };

in with myTypes; {
  boolOption = default: description:
    mkOption {
      type = bool;
      default = usePlugDef default;
      description = escapeXML description;
    };

  # This is a version of boolOption that does always have a fixed value
  boolOptionStrict = default: description:
    mkOption {
      type = bool;
      default = default;
      description = escapeXML description;
    };

  intOption = default: description:
    mkOption {
      type = int;
      default = usePlugDef default;
      description = escapeXML description;
    };

  floatOption = default: description:
    mkOption {
      type = float;
      default = usePlugDef default;
      description = escapeXML description;
    };

  strOption = default: description:
    mkOption {
      type = str;
      default = usePlugDef default;
      description = escapeXML description;
    };

  rawLuaOption = default: description:
    mkOption {
      type = rawLuaType;
      default = rawLua (usePlugDef default);
      description = escapeXML description;
    };

  rawLuaOptionExample = default: description: example:
    mkOption {
      type = rawLuaType;
      default = rawLua (usePlugDef default);
      description = escapeXML description;
      example = example;
    };

  attrsOption = default: description:
    mkOption {
      type = attrs;
      default = usePlugDef default;
      description = escapeXML description;
    };

  listOption = default: description:
    mkOption {
      type = list;
      default = usePlugDef default;
      description = escapeXML description;
    };

  enumOption = enums: default: description:
    mkOption {
      type = enum enums;
      default = usePlugDef default;
      description = escapeXML description;
    };

  boolNullOption = description:
    mkOption {
      type = types.nullOr types.bool;
      default = null;
      description = escapeXML description;
    };

  intNullOption = description:
    mkOption {
      type = types.nullOr types.int;
      default = null;
      description = escapeXML description;
    };

  strNullOption = description:
    mkOption {
      type = types.nullOr types.str;
      default = null;
      description = escapeXML description;
    };

  typeOption = type: default: description:
    mkOption {
      inherit type;
      default = usePlugDef default;
      description = escapeXML description;
    };

}
