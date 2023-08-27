{ self, super, lib }:

let
  inherit (lib)
    elem
    filter
    stringAsChars
    stringToCharacters
    concatStringsSep
    lowerChars
    upperChars
    mapAttrs'
    toLower;

  inherit (builtins) head;

  to_lua_object = import ./src/to_lua_object.nix { inherit lib super; };

in {
  toLuaObject' = to_lua_object;

  # Same as toLuaObject' but with indent set to 0
  toLuaObject = args: to_lua_object 0 args;

  boolToInt = bool: if bool then 1 else 0;

  boolToLuaInt = bool: self.toLuaObject (if bool then 1 else 0);

  # Input: String
  # Output: snake_case String
  camelToSnake = string:
    let

      isChar  = x:
        elem x lowerChars || elem x upperChars;

      isUpper = x: elem x upperChars; # check if x is uppercase

      # exchange any uppercase x letter by '_x', leave lower case letters
      exchangeIfUpper = (x:
          if isUpper x then
            "_${toLower x}"
          else
            x
        );

      chars = stringToCharacters string;

      firstChar = head chars;

    in if isUpper firstChar then # do nothing if first char is uppercase
      string
    else if ! isChar firstChar then # do nothing first char is no alphabetical letter
      string
    else
      stringAsChars exchangeIfUpper string;


  # input: attribute set with camelCase keys
  # output: attribute set with snake_case keys
  attrKeysToSnake = attrs:
    mapAttrs'
      (key: value: { name = self.camelToSnake key; value = value; })
      attrs;

  # Input: list of strings
  # Output: lines (srings concatenated with '\n'
  #
  # Removes empty strings and applies concatStringsSep
  toConfigString = list:
    let
      filtered = filter (str: str != "") list;
    in
    concatStringsSep "\n" filtered;
}
