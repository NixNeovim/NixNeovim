{ pkgs, lib, helpers, ... }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  name = "rust-tools";
  pluginUrl = "https://github.com/simrat39/rust-tools.nvim";

  inherit (helpers.custom_options)
    intOption
    strOption
    listOption
    rawLuaOptionExample
    boolOption;

  moduleOptions = {
    tools = {
      # automatically call RustReloadWorkspace when writing to a Cargo.toml file.
      reloadWorkspaceFromCargoToml = boolOption true "automatically call RustReloadWorkspace when writing to a Cargo.toml file.";
      # These apply to the default RustSetInlayHints command
      inlayHints = {
        # automatically set inlay hints (type hints)
        # default: true
        auto = boolOption true "";
        # Only show inlay hints for the current line
        onlyCurrentLine = boolOption false "Only show inlay hints for the current line";
        # whether to show parameter hints with the inlay hints or not
        # default: true
        showParameterHints = boolOption true "";
        # prefix for parameter hints
        # default: "<-"
        parameterHintsPrefix = strOption "<- " "";
        # prefix for all the other hints (type, chaining)
        # default: "=>"
        otherHintsPrefix = strOption "=> " "";
        # whether to align to the length of the longest line in the file
        maxLenAlign = boolOption false "whether to align to the length of the longest line in the file";
        # padding from the left if max_len_align is true
        maxLenAlignPadding = intOption 1 "padding from the left if max_len_align is true";
        # whether to align to the extreme right or not
        rightAlign = boolOption false "whether to align to the extreme right or not";
        # padding from the right if right_align is true
        rightAlignPadding = intOption 7 "padding from the right if right_align is true";
        # The color of the hints
        highlight = strOption "Comment" "The color of the hints";
      };
      # options same as lsp hover / vim.lsp.util.open_floating_preview()
      hoverActions = {
        # whether the hover action window gets automatically focused
        # default: false
        autoFocus = boolOption false "";
      };
      # settings for showing the crate graph based on graphviz and the dot
      # command
      crateGraph = {
        # Backend used for displaying the graph
        # see: https://graphviz.org/docs/outputs/
        # default: x11
        backend = strOption "x11" "";
        # true for all crates.io and external crates, false only the local
        # crates
        # default: true
        full = boolOption true "";
        # List of backends found on: https://graphviz.org/docs/outputs/
        # Is used for input validation and autocompletion
        # Last updated: 2021-08-26
        enabledGraphvizBackends = listOption [
          "bmp"
          "cgimage"
          "canon"
          "dot"
          "gv"
          "xdot"
          "xdot1.2"
          "xdot1.4"
          "eps"
          "exr"
          "fig"
          "gd"
          "gd2"
          "gif"
          "gtk"
          "ico"
          "cmap"
          "ismap"
          "imap"
          "cmapx"
          "imap_np"
          "cmapx_np"
          "jpg"
          "jpeg"
          "jpe"
          "jp2"
          "json"
          "json0"
          "dot_json"
          "xdot_json"
          "pdf"
          "pic"
          "pct"
          "pict"
          "plain"
          "plain-ext"
          "png"
          "pov"
          "ps"
          "ps2"
          "psd"
          "sgi"
          "svg"
          "svgz"
          "tga"
          "tiff"
          "tif"
          "tk"
          "vml"
          "vmlz"
          "wbmp"
          "webp"
          "xlib"
          "x11"
        ] "";
      };
    };
    # all the opts to send to nvim-lspconfig
    # these override the defaults set by rust-tools.nvim
    # see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = rawLuaOptionExample null "" ''
      mkRaw \'\'{
        ["on_attach"] = function()
          -- custom lsp code
          -- custom rust-tools code
        end
      }
      \'\'
    '';
    # rust-analyzer options
    # debugging stuff
    dap = {
      adapter = {
        type = strOption "executable" "debugging stuff";
        command = strOption "lldb-vscode" "debugging stuff";
        name = strOption "rt_lldb" "debugging stuff";
      };
    };
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    rust-tools-nvim
  ];

  extraPackages = with pkgs; [
    cargo
    rust-analyzer
  ];

  extraNixNeovimConfig = {
    plugins.lspconfig.enable = true;
  };
}
