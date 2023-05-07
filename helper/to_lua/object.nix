{ lib, indent, camelToSnake }:

let
  inherit (lib)
    boolToString
    concatMapStringsSep
    concatStringsSep
    filterAttrs
    hasAttr
    length
    mapAttrsToList
    stringToCharacters;
  inherit (builtins) head;

  # Converts a bunch of different Nix types to their lua equivalents!
  # initDepth is only used for styling the lua output
  toLuaObject' = initDepth: args:
    let
      # helper function that keeps track of indentation (depth)
      toLuaObjectHelper = depth: args:
        let ind = indent depth;
        in
          if builtins.isAttrs args then
            let
              nonNullArgs = filterAttrs
                (name: value:
                  !isNull value # && toLuaObject value != "{}"
                )
                args;
            in
              if hasAttr "__raw" nonNullArgs then
                nonNullArgs.__raw
              else
                let
                  argToLua = name: value:
                    if head (stringToCharacters name) == "@" then
                      toLuaObjectHelper (depth + 1) value
                    else
                      "[${camelToSnake (toLuaObjectHelper 0 name)}] = ${toLuaObjectHelper (depth + 1) value}";

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
    in
    toLuaObjectHelper initDepth args;

in {
  inherit toLuaObject';

  toLuaObject = args: toLuaObject' 0 args;
}
