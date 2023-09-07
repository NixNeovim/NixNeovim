{ pkgs, lib, helpers, ... }:

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "wilder";
  pluginUrl = "https://github.com/gelguy/wilder.nvim";

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    intOption
    boolOption;

  moduleOptions = {
    # add module options here
    modes = listOption ["/" "?"] ''
      List of modes which wilder will be active in.
      Possible elements: '/', '?' and ':'
    '';

    enableCmdlineEnter = boolOption true ''
        If true calls wilder#enable_cmdline_enter().
        Creates a new |CmdlineEnter| autocmd to which will start wilder
        when the cmdline is entered.
      '';

      wildcharm = strOption "&wildchar" ''
        Key to set the 'wildcharm' option to. can be set to v:false to skip the setting.
      '';

      nextKey = strOption "<Tab>" ''
        A key to map to wilder#next() providing next suggestion.
      '';

      prevKey = strOption "<S-Tab>" ''
        A key to map to wilder#prev() providing previous suggestion.
      '';

      acceptKey = strOption "<Down>" ''
        Mapping to bind to wilder#accept_completion().
      '';

      rejectKey = strOption "<Up>" ''
        Mapping to bind to wilder#reject_completion().
      '';

      acceptCompletionAutoSelect = boolOption true ''
        The auto_slect option passed to wilder#accept_completion().
      '';
  };



in mkLuaPlugin {

# Consider the following additional options:
#
# extraDescription ? "" # description added to the enable function
# extraPackages ? [ ]   # non-plugin packages
# extraConfigLua ? "" # lua config added to the init.vim
# extraConfigVim ? ""   # vim config added to the init.vim
# defaultRequire ? true # add default requrie string?
# extraOptions ? {}     # extra vim options like line numbers, etc
# extraNixNeovimConfig ? {} # extra config applied to 'programs.nixneovim'
# isColorscheme ? false # If enabled, plugin will be added to 'nixneovim.colorschemes' instead of 'nixneovim.plugins'

  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    wilder-nvim
  ];
}
