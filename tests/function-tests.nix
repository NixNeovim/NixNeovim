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
    flattenModuleOptions
    camelToSnake
    toLuaObject;

  inherit (helpers.utils)
    rawLua
    getRawLua
    isRawLua;

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

  testRawLua1 = {
    expr = rawLua "require('gitsigns').blame_line{full=true}";
    expected = { __raw = ''require('gitsigns').blame_line{full=true}''; };
  };

  testRawLua2 = {
    expr = isRawLua { __raw = "function end"; };
    expected = true;
  };

  testRawLua3 = {
    expr = isRawLua { };
    expected = false;
  };

  testRawLua4 = {
    expr = isRawLua { __raw = "function end"; otherAttrs = 1; };
    expected = false;
  };

  testRawLua5 = {
    expr = isRawLua (rawLua null);
    expected = true;
  };

  testRawLua6 = {
    expr = getRawLua (rawLua null);
    expected = "nil";
  };

  testRawLuaObject1 = {
    expr = toLuaObject (rawLua "function end");
    expected = "function end";
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

  testConvertModuleOptions1 =
    let
      cfg =
        {
          customConfig1 = true;
          extraConfig = {
            extraConfig1 = true;
            extraConfig2 = "";
          };
        };
    in {
      expr = flattenModuleOptions cfg {
        customConfig1 = null;
      };
      expected = {
          customConfig1 = true;
          extraConfig1 = true;
          extraConfig2 = "";
      };
    };
}
