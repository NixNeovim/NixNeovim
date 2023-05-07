{ lib, customOptions, config }:

let
  inherit (lib)
    elem
    stringAsChars
    stringToCharacters
    toLower;
  inherit (builtins) head split;

  # takes camalCase string and converts it to snake_case
  camelToSnake = string:
    let

      upperCaseLetters = split "" "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

      isUpper = x: elem x upperCaseLetters; # check if x is uppercase

      # exchange any uppercase x letter by '_x', leave lower case letters
      exchangeIfUpper = (x:
          if isUpper x then
            "_${toLower x}"
          else
            x
        );

      chars = stringToCharacters string;

    in if !isUpper (head chars) then
      stringAsChars exchangeIfUpper string
    else
      string;

  repeatChar = char: n:
    if n == 0 then
      ""
    else
      "  " + repeatChar char (n - 1); # 2 spaces

  # create indentation string
  indent = depth: repeatChar " " depth;

  object = import ./object.nix { inherit lib indent camelToSnake; };
  plugin = import ./mk_plugin.nix {
    inherit
      lib
      customOptions
      camelToSnake
      config
      indent;
    inherit (object)
      toLuaObject;
  };
in {

  # exported functions
  inherit
    camelToSnake
    indent
    plugin
    object;
  inherit (object)
    toLuaObject'
    toLuaObject;
  inherit (plugin)
    convertModuleOptions
    defaultModuleOptions
    mkLuaPlugin;

}
