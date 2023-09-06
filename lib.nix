{

  # Creates a 'special' attribute set that is recogniced as lua code in mkLuaObject
  rawLua = lua: { __raw = lua; };

  mappingHelper = {
    mkMap = action: desc: { inherit action desc; };

    mkExpr = action: desc: { inherit action desc; expr = true; };
  };

}
