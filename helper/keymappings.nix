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
    (genMaps "" cfg.mappings.normalVisualOp) ++
    (genMaps "n" cfg.mappings.normal) ++
    (genMaps "i" cfg.mappings.insert) ++
    (genMaps "v" cfg.mappings.visual) ++
    (genMaps "x" cfg.mappings.visualOnly) ++
    (genMaps "s" cfg.mappings.select) ++
    (genMaps "t" cfg.mappings.terminal) ++
    (genMaps "o" cfg.mappings.operator) ++
    (genMaps "l" cfg.mappings.lang) ++
    (genMaps "!" cfg.mappings.insertCommand) ++
    (genMaps "c" cfg.mappings.command);

}
