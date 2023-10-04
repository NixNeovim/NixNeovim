{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
    mkLuaPlugin;

  name = "fm-nvim";
  pluginUrl = "https://github.com/is0n/fm-nvim";

  inherit (helpers.custom_options) intOption floatOption strOption enumOption;

  moduleOptions = {
    # (Vim) Command used to open files
    editCmd = strOption "edit" "(Vim) Command used to open files";
    # See `Q&A` for more info
    onClose = {};
    onOpen = {};
    # UI Options
    ui = {
      # Default UI (can be "split" or "float")
      default = enumOption ["float" "split"] "float" "Default UI (can be \"split\" or \"float\")";
      float = {
        # Floating window border (see ':h nvim_open_win')
        border = strOption "none" "Floating window border (see ':h nvim_open_win')";
        # Highlight group for floating window/border (see ':h winhl')
        floatHl = strOption "Normal" "Highlight group for floating window/border (see ':h winhl')";
        borderHl = strOption "FloatBorder" "Highlight group for floating window/border (see ':h winhl')";
        # Floating Window Transparency (see ':h winblend')
        blend = intOption 0 "Floating Window Transparency (see ':h winblend')";
        # Num from 0 - 1 for measurements
        height = floatOption 0.8 "Num from 0 - 1.0 for measurements";
        width = floatOption 0.8 "Num from 0 - 1.0 for measurements";
        # X and Y Axis of Window
        x = floatOption 0.5 "X Axis of Window";
        y = floatOption 0.5 "Y Axis of Window";
      };
      split = {
        # Direction of split
        direction = strOption "topleft" "Direction of split";
        # Size of split
        size = intOption 24 "Size of split";
      };
    };
    # Terminal commands used w/ file manager (have to be in your $PATH)
    cmds = {
      lfCmd = strOption "lf" "lf -command 'set hidden'";
      fmCmd = strOption "fm" "";
      nnnCmd = strOption "nnn" "";
      fffCmd = strOption "fff" "";
      twfCmd = strOption "twf" "";
      fzfCmd = strOption "fzf" "fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'";
      fzyCmd = strOption "find . | fzy" "";
      xplrCmd = strOption "xplr" "";
      vifmCmd = strOption "vifm" "";
      skimCmd = strOption "sk" "";
      brootCmd = strOption "broot" "";
      gituiCmd = strOption "gitui" "";
      rangerCmd = strOption "ranger" "";
      joshutoCmd = strOption "joshuto" "";
      lazygitCmd = strOption "lazygit" "";
      neomuttCmd = strOption "neomutt" "";
      taskwarriorCmd = strOption "taskwarrior-tui" "";
    };
    # Mappings used with the plugin
    mappings = {
      vertSplit = strOption "<C-v>" "";
      horzSplit = strOption "<C-h>" "";
      tabedit = strOption "<C-t>" "";
      edit = strOption "<C-e>" "";
      esc = strOption "<ESC>" "";
    };
    # Path to broot config
    brootConf = strOption "vim.fn.stdpath(\"data\") .. \"/site/pack/packer/start/fm-nvim/assets/broot_conf.hjson\"" "Path to broot config";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    fm-nvim
  ];
}
