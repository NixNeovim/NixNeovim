{ pkgs, lib, helpers, config, ... }@args:

let
  inherit (lib.types)
    bool
    int;

  inherit (helpers.deprecated)
    mkDefaultOpt
    mkPlugin;

in mkPlugin { inherit config lib; } {
  name = "ledger";
  description = "Enable ledger language features";
  extraPlugins = [ pkgs.vimPlugins.vim-ledger ];

  options = {
    maxWidth = mkDefaultOpt {
      global = "ledger_maxwidth";
      description = "Number of columns to display foldtext";
      type = int;
    };

    fillString = mkDefaultOpt {
      global = "ledger_fillstring";
      description = "String used to fill the space between account name and amount in the foldtext";
      type = int;
    };

    detailedFirst = mkDefaultOpt {
      global = "ledger_detailed_first";
      description = "Account completion sorted by depth instead of alphabetically";
      type = bool;
    };

    foldBlanks = mkDefaultOpt {
      global = "ledger_fold_blanks";
      description = "Hide blank lines following a transaction on a fold";
      type = bool;
    };
  };
}
