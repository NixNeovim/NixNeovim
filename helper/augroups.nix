{ lib
, toLuaObject
}:
let
  inherit (import ../lib.nix) rawLua;

  inherit (lib) mkOption;
  inherit (lib.strings) concatMapStringsSep;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.types) either bool str listOf nullOr submodule lines int;

  autocmdOpts = {
    options = {
      event = mkOption {
        # TODO: make enum of nvim events
        type = either str (listOf str);
        description = ''
          Event(s) that will trigger the handler (callback or command).
        '';
      };
      pattern = mkOption {
        default = null;
        type = nullOr (either str (listOf str));
        description = ''
          Pattern(s) to match literally.

          Note: `pattern` is NOT automatically expanded (unlike with |:autocmd|), thus names like
          "$HOME" and "~" must be expanded explicitly.
        '';
      };
      buffer = mkOption {
        default = null;
        type = nullOr int;
        description = ''
          buffer number for buffer-local autocommands. Cannot be used with pattern.
        '';
      };
      desc = mkOption {
        default = null;
        type = nullOr lines;
        description = ''
          description (for documentation and troubleshooting)
        '';
      };
      luaCallback = mkOption {
        default = null;
        type = nullOr lines;
        description = ''
          Lua function called when the event(s) is triggered.
          Can return true to delete the autocommand, and receives a table argument (opts) with these keys:
             • id: (number) autocommand id
             • event: (string) name of the triggered event |autocmd-events|
             • group: (number|nil) autocommand group id, if any
             • match: (string) expanded value of |<amatch>|
             • buf: (number) expanded value of |<abuf>|
             • file: (string) expanded value of |<afile>|
             • data: (any) arbitrary data passed from |nvim_exec_autocmds()|

          Will be expanded to:

          ```lua
          function(opts)
            ''${luaCallback}
          end
          ```
        '';
        example = ''
          vim.highlight.on_yank {
            higroup = (
              vim.fn['hlexists'] 'HighlightedyankRegion' > 0 and 'HighlightedyankRegion' or 'IncSearch'
            ),
            timeout = 200,
          }
        '';
      };
      vimCallback = mkOption {
        default = null;
        type = nullOr str;
        description = ''
          Vimscript function name called when the event(s) is triggered.

          Conflicts with luaCallback
        '';
      };
      command = mkOption {
        default = null;
        type = nullOr str;
        description = ''
          Vim command to execute on event. Cannot be used with {lua,vim}Callback
        '';
      };
      once = mkOption {
        default = false;
        type = bool;
        description = ''
          Run the autocommand only once |autocmd-once|
        '';
      };
      nested = mkOption {
        default = false;
        type = bool;
        description = ''
          Run nested autocommands |autocmd-nested|.
        '';
      };
    };
  };

  quote = string: "\"${string}\"";

  toLuaStringList = strings:"{${concatMapStringsSep "," quote strings}}";

  genAutocmd = group: { event
               , pattern
               , buffer
               , desc
               , luaCallback
               , vimCallback
               , command
               , once
               , nested
               }: let
               # TODO: Assert that only one of luaCallback vimCallback or command is set
               events = if builtins.isList event then toLuaStringList event else "{${quote event}}";
               opts = {
                 inherit group pattern buffer desc command once nested;
                 callback = if luaCallback == null then
                   vimCallback
                 else
                   rawLua ''
                   function(opts)
                     ${luaCallback}
                   end
                   '';
               };
             in ''
    do
      local events = ${events}
      local opts = ${toLuaObject opts}
      vim.api.nvim_create_autocmd(events, opts)
    end
  '';

  genAugroup = {name, autocmds, clear}: let
    opts = toLuaObject {inherit clear;};
    group = rawLua "group";
    autocmds' = concatMapStringsSep "\n" (genAutocmd group) autocmds;
  in ''
    do
      local group = vim.api.nvim_create_augroup(${quote name}, ${opts})
      ${autocmds'}
    end
  '';

  genAugroups = augroups:
    let
      setName = name: opts: {inherit name;} // opts;
      augroups' = mapAttrsToList setName augroups;
    in
      concatMapStringsSep "\n" genAugroup augroups';
in {
  augroupOptions = submodule {
    options = {
      name = mkOption {
        type = str;
        description = ''
          The name of the augroup. If undefined, the name of the attribute set will be used.
        '';
      };
      autocmds = mkOption {
        type = listOf (submodule autocmdOpts);
        description = ''
          The autocmds that are part of this augroup.

          See :help nvim_create_autocmd()
        '';
      };
      clear = mkOption {
        default = true;
        type = bool;
        description = ''
          Clear existing commands if the group already exists.
        '';
      };
    };
  };

  luaString = genAugroups;
}
