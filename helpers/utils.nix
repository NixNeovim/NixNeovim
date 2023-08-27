# TODO: crreate function is Raw

{ lib, self }:

let
  inherit (lib)
    flatten
    mapAttrsToList
    attrNames
    assertMsg;

  inherit (builtins)
    filterAttrs
    hasAttr
    isAttrs;

  checkRawLua = lua:
    assert assertMsg (isAttrs lua) "Function isRawLua failed: input is not of a raw lua string (is not type Attrs)\n - '${lua}'";
    assert assertMsg (hasAttr "__raw" lua) "Function isRawLua failed: input dows not have __raw attribute\n - '${lua}'";
    assert assertMsg (filterAttrs (key: _: key != "__raw") lua == {}) "Function isRawLua failed: input has unrecognised attributes\n - '${lua}'";
    lua;

  # filters activated options from a set
  activated = cfg: options: filterAttrs (name: attrs: cfg.${name}.enable) options;

in {

  # Input: char, int
  #
  # Repeat char n times
  repeatChar = char: n:
    if n == 0 then
      ""
    else
      "  " + self.repeatChar char (n - 1); # 2 spaces

  # Input: int
  indent = depth: self.repeatChar " " depth;

  rawLua = lua: { __raw = lua; };

  # Input: attr
  # Output: bool
  #
  # Checks if the input is a correct raw lua attribute set
  isRawLua = lua:
    let
      correctType = isAttrs lua;
      hasRawAttr = hasAttr "__raw" lua;
      hasOnlyRawAttr = filterAttrs (key: _: key != "__raw") lua == {};
    in correctType && hasRawAttr && hasOnlyRawAttr;

  # Input: raw lua attribute set
  #
  # returns the raw lua code, if the input is of correct type
  getRawLua = lua: (checkRawLua lua).__raw;

  # remove the enable key from a attribute set
  removeEnable = attrs:
    filterAttrs (n: _: n != "enable") attrs;


  ##############################################################################
  # helper functions for plugins with sub-plugins like cmp, lsp, telescope, etc.

  # returns a list of the names of all activated options
  activatedNames = cfg: options: attrNames (activated cfg options);

  # Input: cfg, options of sub-plugins
  # Output: activated sub-plugins
  activatedPackages = cfg: options:
    flatten (mapAttrsToList (name: attrs: attrs.packages) (activated cfg options));

  activatedLuaNames = cfg: options:
    flatten (mapAttrsToList (name: attrs: attrs.luaName) (activated cfg options));

  activatedPlugins = cfg: options:
    flatten (mapAttrsToList (name: attrs: attrs.plugins) (activated cfg options));

  activatedConfig = cfg: options:
    mapAttrsToList (name: attrs: attrs.extraConfig) (activated cfg options);
}
