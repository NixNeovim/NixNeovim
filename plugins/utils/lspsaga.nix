{ pkgs, lib, config, ... }:
let
  name = "lspsaga";
  pluginUrl = "https://github.com/nvimdev/lspsaga.nvim";
  
  helpers = import ../../helper { inherit pkgs lib config; };
  inherit (helpers.customOptions)
    strOption
    intOption
    boolOption
    listOption;

  moduleOptions = {
    hover = {
      openLink = strOption "gx" "";
      openBrowser = strOption "!chrome" "";
    };
    diagnostic = {
      showCodeAction = boolOption true "It will show available actions in the diagnsotic jump window.";
      showSource = boolOption true "Extend source into the diagnostic message.";
      jumpNumShortcut = boolOption true "After jumping, Lspasga will automatically bind code actions to a number. Afterwards, you can press the number to execute the code action. After the floating window is closed, these numbers will no longer be tied to the same code actions.";
      keys = {
        execAction = strOption "o" "";
        quit = strOption "q" "";
        expandOrJump = strOption "<CR>" "";
        quitInShow = listOption [
          "q"
            "<ESC>"
        ] "";
      };
    };
    codeAction = {
      numShortcut = boolOption true "";
      extendGitsigns = boolOption false "";
      keys = {
        quit = strOption "q" "";
        exec = strOption "<CR>" "";
      };
    };
    lightbulb = {
      enable = boolOption true "";
      enableInInsert = boolOption true "";
      sign = boolOption true "";
      virtualText = boolOption true "";
    };
    preview = {
      linesAbove = intOption 0 "";
      linesBelow = intOption 10 "";
    };
    scrollPreview = {
      scrollDown = strOption "<C-f>" "";
      scrollUp = strOption "<C-b>" "";
    };
    requestTimeout = intOption 2000 "";
    finder = {
      keys = {
        jumpTo = strOption "p" "Finder peek window.";
        expandOrJump = strOption "o" "";
        vsplit = strOption "s" "";
        split = strOption "i" "";
        tabe = strOption "t" "";
        tabnew = strOption "r" "";
        quit = listOption [
          "q"
            "<ESC>"
        ] "";
        closeInPreview = strOption "<ESC>" "";
      };
    };
    definition = {
      edit = strOption "<C-c>o" "";
      vsplit = strOption "<C-c>v" "";
      split = strOption "<C-c>i" "";
      tabe = strOption "<C-c>t" "";
      quit = strOption "q" "";
    };
    rename = {
      quit = strOption "<C-c>" "";
      exec = strOption "<CR>" "";
      inSelect = boolOption true "";
    };
    symbolInWinbar = {
      enable = boolOption true "";
      separator = strOption " " "";
      showFile = boolOption true "";
      colorMode = boolOption true "";
    };
    outline = {
      winPosition = strOption "right" "";
      autoPreview = boolOption true "";
      autoRefresh = boolOption true "";
      autoClose = boolOption true "";
      autoResize = boolOption false "";
      closeAfterJump = boolOption false "";
      keys = {
        expandOrJump = strOption "o" "";
        quit = strOption "q" "";
      };
    };
    callhierarchy = {
      showDetail = boolOption false "";
      keys = {
        edit = strOption "e" "";
        vsplit = strOption "s" "";
        split = strOption "i" "";
        tabe = strOption "t" "";
        jump = strOption "o" "";
        quit = strOption "q" "";
        expandCollapse = strOption "u" "";
      };
    };
    beacon = {
      enable = boolOption true "";
      frequency = intOption 7 "";
    };
  };

in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [ lspsaga-nvim ];
}
