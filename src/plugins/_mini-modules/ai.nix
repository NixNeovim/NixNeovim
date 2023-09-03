{ lib, helpers, ... }:

let

  inherit (lib) mkOption;
  inherit (lib.types) enum attrs;

  inherit (helpers.custom_options)
    intOption
    strOption;

in {
  searchMethod = mkOption {
    type = enum [ "cover" "cover_or_next" "cover_or_prev" "cover_or_nearest" "next" "previous" "nearest" ];
    default = "cover_or_next";
  };
  nLines = intOption 50 "Number of lines within which textobject is searched";
  customTextobjects = mkOption {
    type = attrs;
    default = { };
    description = "Attribute set with textobect id as key and textobkect specification as values";
  };
  mappings = {
    around = strOption "a" "";
    inside = strOption "i" "";

    aroundNext = strOption "an" "";
    insideNext = strOption "in" "";
    aroundLast = strOption "al" "";
    insideLast = strOption "il" "";

    gotoLeft = strOption "g[" "";
    gotoRight = strOption "g]" "";
  };
}
