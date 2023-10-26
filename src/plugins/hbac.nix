{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "hbac";
  pluginUrl = "https://github.com/axkirillov/hbac.nvim";

  inherit (helpers.custom_options)
    strOption
    intOption
    boolOption;

  inherit (helpers.generator)
    mkLuaPlugin;


  moduleOptions = {
    autoclose = boolOption true "";
    # set autoclose to false if you want to close manually
    threshold = intOption 10 "set autoclose to false if you want to close manually";
    # hbac will start closing unedited buffers once that number is reached
    closeBuffersWithWindows = boolOption false "hbac will start closing unedited buffers once that number is reached";
    # hbac will close buffers with associated windows if this option is `true`
    telescope = {
      mappings = {
        n = {
          closeUnpinned = strOption "<M-c>" "";
          deleteBuffer = strOption "<M-x>" "";
          pinAll = strOption "<M-a>" "";
          unpinAll = strOption "<M-u>" "";
          toggleSelections = strOption "<M-y>" "";
        };
        i = {
          closeUnpinned = strOption "<M-c>" "";
          deleteBuffer = strOption "<M-x>" "";
          pinAll = strOption "<M-a>" "";
          unpinAll = strOption "<M-u>" "";
          toggleSelections = strOption "<M-y>" "";
        };
      };
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    telescope-nvim
    hbac-nvim
    plenary-nvim
    nvim-web-devicons
  ];
}
