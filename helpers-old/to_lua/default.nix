{ lib, customOptions, config }:

let
  inherit (lib)
    elem
    stringAsChars
    stringToCharacters
    lowerChars
    upperChars
    toLower;
  inherit (builtins) head;


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
    toLuaObject
    boolToInt
    boolToInt';
  inherit (plugin)
    convertModuleOptions
    defaultModuleOptions
    mkLuaPlugin;

}
