{ pkgs, lib, config, ... }:

let
  helper = import ./plugins/helpers.nix { inherit lib config; };
in {
  testShortList = {
    expr = helper.toLuaObject { a = 1; };
    expected = "{ [\"a\"] = 1 }";
  };

  testLongList = {
    expr = helper.toLuaObject [ 1 2 3 ];
    expected =
''{
  1,
  2,
  3
}'';
  };

  testToLuaObject1 = {
    expr = helper.toLuaObject true;
    expected = "true";
  };

  testToLuaObject2 = {
    expr = helper.toLuaObject false;
    expected = "false";
  };

  testSnakeCase = {
    expr = helper.camelToSnake "camalCaseString";
    expected = "camal_case_string";
  };

  testSnakeCase2 = {
    expr = helper.camelToSnake "snake_string";
    expected = "snake_string";
  };

  testSnakeCase3 = {
    expr = helper.camelToSnake "snake_1tring";
    expected = "snake_1tring";
  };

  testConfigString = {
    expr = helper.toConfigString [ "1" "2" "" "345" ];
    expected = ''
    1
    2
    345'';
  };
}
