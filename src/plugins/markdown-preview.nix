{ pkgs, lib, helpers, config }:

with lib;

let
  inherit (helpers.generator)
     mkLuaPlugin;

  inherit (helpers.converter)
    toLuaObject;

  name = "markdown-preview";
  pluginUrl = "https://github.com/davidgranstrom/nvim-markdown-preview";

  cfg = config.programs.nixneovim.plugins.${name};

  inherit (helpers.custom_options)
    strOption
    listOption
    enumOption
    boolOption;

  moduleOptions = {
    autoStart = boolOption false "Open the preview window after entering the markdown buffer";
    autoClose = boolOption true "Auto close current preview window when change from markdown buffer to another buffer";
    refreshSlow = boolOption false "Refresh markdown when save the buffer or leave from insert mode, default false is auto refresh markdown as you edit or move the cursor";
    commandForGlobal = boolOption false "Enable markdown preview for all files (by default, the plugin is only enabled for markdown files)";
    openToTheWorld = boolOption false "Make the preview server available to others in your network. By default, the server listens on localhost (127.0.0.1).";
    openIp = strOption "" ''
      Custom IP used to open the preview page. This can be useful when you work in remote vim and preview on local browser.
      For more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9.
    '';
    browser = strOption "" "The browser to open the preview page";
    echoPreviewUrl = boolOption false "Echo preview page url in command line when opening the preview page";
    browserFunc = strOption "" "A custom vim function name to open preview page. This function will receive url as param.";
    markdownCss = strOption "" "Custom markdown style. Must be an absolute path like '/Users/username/markdown.css' or expand('~/markdown.css').";
    highlightCss = strOption "" "Custom highlight style. Must be an absolute path like '/Users/username/highlight.css' or expand('~/highlight.css').";
    port = strOption "" "Custom port to start server or empty for random";
    pageTitle = strOption "「$${name} 」" "preview page title. $${name} will be replaced with the file name.";
    fileTypes = listOption [ "markdown" ] "Recognized filetypes. These filetypes will have MarkdownPreview... commands.";
    theme = enumOption [ "dark" "light"] "dark" "Default theme (dark or light). By default the theme is define according to the preferences of the system.";
  };

in mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    # add neovim plugin here
    nvim-markdown-preview
  ];
  extraConfigLua = ''
    vim.g.mkdp_auto_start = ${toLuaObject cfg.autoStart}
    vim.g.mkdp_auto_close = ${toLuaObject cfg.autoClose}
    vim.g.mkdp_refresh_slow = ${toLuaObject cfg.refreshSlow}
    vim.g.mkdp_command_for_global = ${toLuaObject cfg.commandForGlobal}
    vim.g.mkdp_open_to_the_world = ${toLuaObject cfg.openToTheWorld}
    vim.g.mkdp_open_ip = ${toLuaObject cfg.openIp}
    vim.g.mkdp_browser = ${toLuaObject cfg.browser}
    vim.g.mkdp_echo_preview_url = ${toLuaObject cfg.echoPreviewUrl}
    vim.g.mkdp_browserfunc = ${toLuaObject cfg.browserFunc}
    vim.g.mkdp_markdown_css = ${toLuaObject cfg.markdownCss}
    vim.g.mkdp_highlight_css = ${toLuaObject cfg.highlightCss}
    vim.g.mkdp_port = ${toLuaObject cfg.port}
    vim.g.mkdp_page_title = ${toLuaObject cfg.pageTitle}
    vim.g.mkdp_filetypes = ${toLuaObject cfg.fileTypes}
    vim.g.mkdp_theme = ${toLuaObject cfg.theme}
  '';
  defaultRequire = false;
}
