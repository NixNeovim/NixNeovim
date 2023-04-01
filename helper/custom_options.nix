{ mkOption, types }:

{
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

  listOption = default: description: mkOption {
    type = types.listOf types.anything;
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

}
