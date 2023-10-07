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
    mapAttrs
    toLower;

  inherit (self)
    camelToSnake;

  inherit (builtins)
    attrNames
    head;

  to_lua_object = import ./src/to_lua_object.nix { inherit lib super; };

in {
  toLuaObject' = initDepth: args: to_lua_object initDepth camelToSnake args;

  # Same as toLuaObject' but with indent set to 0
  toLuaObject = args: to_lua_object 0 camelToSnake args;

  # same as toLuaObject' but caller can specify custom converter function
  toLuaObjectCustomConverter' = to_lua_object;

  # same as toLuaObject but caller can specify custom converter function
  toLuaObjectCustomConverter = to_lua_object 0;


  # vim dictionaries are, in theory, compatible with JSON
  toVimDict = args: builtins.toJSON
    (lib.filterAttrs (n: v: !isNull v) args);

  # Input: config, options attributes from module
  # Output: Attribute set of lua options # todo: clarify
  #
  # adds the 'extraAttrs'
  flattenModuleOptions = cfg: moduleOptions:
    let
      attrs = mapAttrs (k: v: cfg.${k}) moduleOptions;
      extraAttrs = cfg.extraConfig;
    in
    attrs // extraAttrs;

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
  toNeovimConfigString = list:
    let
      filtered = filter (str: str != "") list;
    in
    concatStringsSep "\n" filtered;

  # Input: list of vim plugin options
  # Output: vim config string
  toVimOptions = cfg: prefix: options:
    assert builtins.typeOf prefix == "string";
    let
      f = variable: "vim.g.${prefix}_${self.camelToSnake variable} = ${self.toLuaObject cfg.${variable}}";
    in concatStringsSep "\n" (map f (attrNames options));
}
