 { lib, super }:

 let

  inherit (super.utils)
    isRawLua
    getRawLua
    indent;

  inherit (super.converter)
    camelToSnake;

  inherit (lib)
    boolToString
    concatMapStringsSep
    concatStringsSep
    filterAttrs
    length
    mapAttrsToList
    stringToCharacters;

  inherit (builtins) head;

  # filter attributes that are null
  # TODO: this also filters rawLua values that are null
  filterNull = attrs:
    filterAttrs (_: value: !isNull value || isRawLua value && !isNull getRawLua value) attrs;

 in

  # Converts a bunch of different Nix types to their lua equivalents!
  # initDepth is only used for styling the lua output

  initDepth: args:

    let
      # helper function that keeps track of indentation (depth)
      toLuaObjectHelper = depth: args:
        let ind = indent depth;
        in
          if isRawLua args then
            getRawLua args
          else if builtins.isAttrs args then
            let
              nonNullArgs = filterNull args;
            in
              let
                argToLua = name: value:
                  if head (stringToCharacters name) == "@" then
                    toLuaObjectHelper (depth + 1) value
                  else
                    "[${toLuaObjectHelper 0 (camelToSnake name)}] = ${toLuaObjectHelper (depth + 1) value}";

                listOfValues = mapAttrsToList argToLua nonNullArgs;
              in
                if length listOfValues == 0 then
                  "{}"
                else if length listOfValues == 1 then
                  "{ ${head listOfValues} }"
                else
                  ''
                    {
                    ${ind}  ${concatStringsSep ",\n${ind}  " listOfValues}
                    ${ind}}''
          else if builtins.isList args then
            if length args == 0 then
              "{}"
            else
              ''
                {
                ${ind}  ${concatMapStringsSep ",\n${ind}  " (toLuaObjectHelper depth) args}
                ${ind}}'' # this is concatMap not concat
          else if builtins.isString args then
          # This should be enough!
            builtins.toJSON args
          else if builtins.isPath args then
            builtins.toJSON (toString args)
          else if builtins.isBool args then
            "${ boolToString args }"
          else if builtins.isFloat args then
            "${ toString args }"
          else if builtins.isInt args then
            "${ toString args }"
          else if isNull args then
            "nil"
          else "";
    in toLuaObjectHelper initDepth args
