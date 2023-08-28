{ lib, haumea, ... }:

let
  helpers = haumea.lib.load {
    src = ../helpers;
    inputs = {
      inherit lib;
      usePluginDefaults = false;
    };
  };

  inherit (helpers.converter)
    toNeovimConfigString
    camelToSnake
    toLuaObject;

  simpleCheck = expr: expected: { inherit expr expected; };

in {
  testShortList = {
    expr = toLuaObject { a = 1; };
    expected = "{ [\"a\"] = 1 }";
  };

  testLongList = {
    expr = toLuaObject [ 1 2 3 ];
    expected =
''{
  1,
  2,
  3
}'';
  };

  testToLuaObject1 = {
    expr = toLuaObject true;
    expected = "true";
  };

  testToLuaObject2 = {
    expr = toLuaObject false;
    expected = "false";
  };

  testToLuaObject3 = {
    expr = toLuaObject "<cmd>lua require('gitsigns').blame_line{full=true}<cr>";
    expected = ''"<cmd>lua require('gitsigns').blame_line{full=true}<cr>"'';
  };

  testSnakeCase = {
    expr = camelToSnake "camalCaseString";
    expected = "camal_case_string";
  };

  testSnakeCase2 = {
    expr = camelToSnake "snake_string";
    expected = "snake_string";
  };

  testSnakeCase3 = {
    expr = camelToSnake "snake_1tring";
    expected = "snake_1tring";
  };

  testSnakeCase4 = {
    expr = camelToSnake "AARRGGBB";
    expected = "AARRGGBB";
  };

  testSnakeCase5 = {
    expr = camelToSnake "<C-n>";
    expected = "<C-n>";
  };

  testConfigString = {
    expr = toNeovimConfigString [ "1" "2" "" "345" ];
    expected = ''
    1
    2
    345'';
  };
}
