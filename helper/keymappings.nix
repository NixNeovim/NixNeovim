{ lib, config, ... }:

let
  inherit (builtins) isString isAttrs mapAttrs;
  inherit (lib) filterAttrs assertMsg mapAttrsToList;

  cfg = config.programs.nixneovim;

  # Right hand side of mapping can be a string or an attribute set
  # This function transforms both into a common attribute set
  normalizeRhs = rhs:
    assert assertMsg (isString rhs || isAttrs rhs)
      "Could not build keymappings: Rhs has to be string or attribute set";
    if isString rhs then
      {
        silent = false;
        expr = false;
        unique = false;
        noremap = true;
        script = false;
        nowait = false;
        action = rhs;
      }
    else
      rhs;

  # Generates maps for a lua config
  genMaps = mode: maps:
    let
      normalizedMaps = builtins.mapAttrs
        (key: action: normalizeRhs action) maps;

      # filter inactive options
      filterActive = attrs: filterAttrs (_: v: v) attrs;
        
    in mapAttrsToList
      (key: mapping:
        {
          mode = mode;
          key = key;
          action = mapping.action;
          config = filterActive {
            inherit (mapping) silent expr unique noremap script nowait;
          };
        }
      )
      normalizedMaps;

   # TODO: implement something like this: https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/basics.lua#L633

in {

  list =
    (genMaps "" cfg.maps.normalVisualOp) ++
    (genMaps "n" cfg.maps.normal) ++
    (genMaps "i" cfg.maps.insert) ++
    (genMaps "v" cfg.maps.visual) ++
    (genMaps "x" cfg.maps.visualOnly) ++
    (genMaps "s" cfg.maps.select) ++
    (genMaps "t" cfg.maps.terminal) ++
    (genMaps "o" cfg.maps.operator) ++
    (genMaps "l" cfg.maps.lang) ++
    (genMaps "!" cfg.maps.insertCommand) ++
    (genMaps "c" cfg.maps.command);

}
