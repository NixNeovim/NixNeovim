{ lib, super }:

let
  inherit (builtins) isString isAttrs;
  inherit (lib) filterAttrs assertMsg mapAttrsToList mkOption;
  inherit (lib.types) either str submodule attrsOf;

  inherit (super.custom_options) boolOption strNullOption;
  # inherit (helpers) toLuaObject;

  # Type definitions for key mappings
  mapOption = submodule {
    options = {
      silent      = boolOption false "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";
      nowait      = boolOption false "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";
      script      = boolOption false "Equivalent to adding <script> to a map.";
      expr        = boolOption false "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";
      unique      = boolOption false "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";
      noremap     = boolOption false "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";
      action      = strNullOption "The action to execute";
      # actionLua   = strNullOption "The lua function to execute";
      desc        = strNullOption "A textual description of this keybind, to be shown in which-key (or similar plugins).";

      __raw = mkOption {
        type = str;
        visible = false;
      };
    };
  };

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
        desc = null;
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
      (key: mapping: {
          mode = mode;
          key = key;
          action = mapping.action;
          config = filterActive {
            inherit (mapping) silent expr unique noremap script nowait;
          } // { inherit (mapping) desc; };
        }
      )
      normalizedMaps;

  genAllMaps = mappings:
    (genMaps ""  mappings.normalVisualOp) ++
    (genMaps "n" mappings.normal) ++
    (genMaps "i" mappings.insert) ++
    (genMaps "v" mappings.visual) ++
    (genMaps "x" mappings.visualOnly) ++
    (genMaps "s" mappings.select) ++
    (genMaps "t" mappings.terminal) ++
    (genMaps "o" mappings.operator) ++
    (genMaps "l" mappings.lang) ++
    (genMaps "!" mappings.insertCommand) ++
    (genMaps "c" mappings.command);

   # TODO: implement something like this: https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/basics.lua#L633

in {


  # options definition for key mappings
  mapOptions = mode: mkOption {
    description = "Mappings for ${mode} mode";
    type = attrsOf (either str mapOption);
    default = { };
  };

  # create the keymapping strings
  luaString = mappings:
    let
      inherit (lib) forEach concatStringsSep;

      string = forEach (genAllMaps mappings)
        ({ mode, key, action, config }:
          ''do vim.keymap.set("${mode}", "${key}", ${action}, ${super.to_lua.object.toLuaObject config}) end''
        );
    in concatStringsSep "\n" string;

}
