{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "todo-comments";
  pluginUrl = "https://github.com/folke/todo-comments.nvim";

  inherit (helpers.custom_options) boolOption intOption strOption;

  keywordModule = { name, config, ... }: {
    options = with helpers; {
      icon = strOption " " "Icon used for the sign and in search results";
      color = strOption "error" "Can be a hex color or a named color";
      alt = mkOption {
        type = with types; either str (listOf str);
        description = "A list of other keywords that map to this keyword";
        example = [ "FIXME" "BUG" "FIXIT" "ISSUE" ];
        default = "";
      };
    };
  };

  moduleOptions = {
    signs = boolOption true "Show icons in the signs column";
    signPriority = intOption 8 "sign_priority";
    keywords = mkOption {
      type = types.nullOr (types.attrsOf (types.submodule keywordModule));
      description = "Keywords recognized as 'todo' comments";
      default = null;
    };
    mergeKeywords = boolOption true "When true, custom keywords will be merged with the defaults";
  };

  pluginOptions = {
    signs = cfg.signs;
    sign_priority = cfg.signPriority;
    keywords = cfg.keywords;
    merge_keywords = cfg.mergeKeywords;
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    todo-comments-nvim
  ];
}
