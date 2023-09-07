{ pkgs, lib, helpers, ... }:

with lib;

let

  name = "bamboo";
  pluginUrl = "https://github.com/ribru17/bamboo.nvim";

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    boolOption;

  moduleOptions = {
    style = enumOption [ "vulgaris" "multiplex" ] "vulgaris" "";
    # Choose between 'vulgaris' (regular) and 'multiplex' (greener)
    # Keybind to toggle theme style. Leave it nil to disable it, or set it to a string, e.g. "<leader>ts"
    toggleStyleList = listOption [
      "vulgaris"
      "multiplex"
    ] "";
    # List of styles to toggle between (this option is essentially pointless now but will become useful if more style variations are added)
    transparent = boolOption false "List of styles to toggle between (this option is essentially pointless now but will become useful if more style variations are added)";
    # Show/hide background
    termColors = boolOption true "Show/hide background";
    # Change terminal color as per the selected theme style
    endingTildes = boolOption false "Change terminal color as per the selected theme style";
    # Show the end-of-buffer tildes. By default they are hidden
    cmpItemkindReverse = boolOption false "Show the end-of-buffer tildes. By default they are hidden";
    # reverse item kind highlights in cmp menu
    # Change code style
    # Options are italic, bold, underline, none
    # You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
    codeStyle = {
      comments = strOption "italic" "You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'";
      keywords = strOption "none" "You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'";
      functions = strOption "none" "You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'";
      strings = strOption "none" "You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'";
      variables = strOption "none" "You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'";
    };
    # Lualine options
    lualine = {
      transparent = boolOption false "";
    };
    # Plugins Config --
    diagnostics = {
      darker = boolOption false "";
      # darker colors for diagnostic
      undercurl = boolOption true "darker colors for diagnostic";
      # use undercurl instead of underline for diagnostics
      background = boolOption true "use undercurl instead of underline for diagnostics";
      # use background color for virtual text
    };
  };

in helpers.generator.mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    bamboo-nvim
  ];
  isColorscheme = true;
  extraConfigLua = ''
    vim.cmd[[ colorscheme bamboo ]]
  '';

}
