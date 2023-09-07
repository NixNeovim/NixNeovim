{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "oil";
  pluginUrl = "https://github.com/stevearc/oil.nvim";

  inherit (helpers.custom_options)
    boolOption
    intOption
    strOption
    listOption;
    

  moduleOptions = {
    # Id is automatically added at the beginning, and name at the end
    # See :help oil-columns
    columns = listOption [ "icon" ] "Other options are \"permissions\" \"size\" \"mtime\"";
    # Buffer-local options to use for oil buffers
    bufOptions = {
      buflisted = boolOption false "Buffer-local options to use for oil buffers";
    };
    # Window-local options to use for oil buffers
    winOptions = {
      wrap = boolOption false "Window-local options to use for oil buffers";
      signcolumn = strOption "no" "Window-local options to use for oil buffers";
      cursorcolumn = boolOption false "Window-local options to use for oil buffers";
      foldcolumn = strOption "0" "Window-local options to use for oil buffers";
      spell = boolOption false "Window-local options to use for oil buffers";
      list = boolOption false "Window-local options to use for oil buffers";
      conceallevel = intOption 3 "Window-local options to use for oil buffers";
      concealcursor = strOption "n" "Window-local options to use for oil buffers";
    };
    # Oil will take over directory buffers (e.g. `vim .` or `:e src/`
    defaultFileExplorer = boolOption true "Oil will take over directory buffers (e.g. `vim .` or `:e src/`";
    # Restore window options to previous values when leaving an oil buffer
    restoreWinOptions = boolOption true "Restore window options to previous values when leaving an oil buffer";
    # Skip the confirmation popup for simple operations
    skipConfirmForSimpleEdits = boolOption false "Skip the confirmation popup for simple operations";
    # Deleted files will be removed with the `trash-put` command.
    deleteToTrash = boolOption false "Deleted files will be removed with the `trash-put` command.";
    # Selecting a new/moved/renamed file or directory will prompt you to save changes first
    promptSaveOnSelectNewEntry = boolOption true "Selecting a new/moved/renamed file or directory will prompt you to save changes first";
    # Set to false to disable all of the above keymaps
    useDefaultKeymaps = boolOption true "Set to false to disable all of the above keymaps";
    viewOptions = {
      # Show files and directories that start with "."
      showHidden = boolOption false "Show files and directories that start with \".\"";
      # This function defines what is considered a "hidden" file
      # This function defines what will never be shown, even when `show_hidden` is set
    };
    # Configuration for the floating window in oil.open_float
    float = {
      # Padding around the floating window
      padding = intOption 2 "Padding around the floating window";
      maxWidth = intOption 0 "Padding around the floating window";
      maxHeight = intOption 0 "Padding around the floating window";
      border = strOption "rounded" "Padding around the floating window";
      winOptions = {
        winblend = intOption 10 "Padding around the floating window";
      };
    };
    # Configuration for the actions floating preview window
    preview = {
      # Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      # min_width and max_width can be a single value or a list of mixed integer/float types.
      # max_width = {100, 0.8} means "the lesser of 100 columns or 80% of total"
      maxWidth = listOption [ 0.9 ] "max_width = [100, 0.8] means \"the lesser of 100 columns or 80% of total\"";
      # min_width = {40, 0.4} means "the greater of 40 columns or 40% of total"
      minWidth = listOption [ 40 0.4 ] "min_width = [40, 0.4] means \"the greater of 40 columns or 40% of total\"";
      # optionally define an integer/float for the exact width of the preview window
      # Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      # min_height and max_height can be a single value or a list of mixed integer/float types.
      # max_height = {80, 0.9} means "the lesser of 80 columns or 90% of total"
      maxHeight = listOption [ 0.9 ] "max_height = [80, 0.9] means \"the lesser of 80 columns or 90% of total\"";
      # min_height = {5, 0.1} means "the greater of 5 columns or 10% of total"
      minHeight = listOption [ 5 0.1 ] "min_height = [5, 0.1] means \"the greater of 5 columns or 10% of total\"";
      # optionally define an integer/float for the exact height of the preview window
      border = strOption "rounded" "optionally define an integer/float for the exact height of the preview window";
      winOptions = {
        winblend = intOption 0 "optionally define an integer/float for the exact height of the preview window";
      };
    };
    # Configuration for the floating progress window
    progress = {
      maxWidth = listOption [ 0.9 ] "Configuration for the floating progress window";
      minWidth = listOption [ 40 0.4 ] "";
      maxHeight = listOption [ 10 0.9 ] "";
      minHeight = listOption [ 5 0.1 ] "";
      border = strOption "rounded" "Configuration for the floating progress window";
      minimizedBorder = strOption "none" "Configuration for the floating progress window";
      winOptions = {
        winblend = intOption 0 "Configuration for the floating progress window";
      };
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    oil-nvim
  ];
}
