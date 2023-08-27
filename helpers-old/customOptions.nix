{ lib, usePluginDefaults }:

let

  inherit (lib)
    mkOption
    types;

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

in with myTypes; {
  boolOption = default: description:
    mkOption {
      type = bool;
      default = usePlugDef default;
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
