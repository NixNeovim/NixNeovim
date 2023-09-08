{ lib, config, pkgs, helpers }:

let

  cfg-sources = config.programs.nixneovim.plugins.nvim-cmp.sources;

  inherit (helpers.custom_options)
    rawLuaOption
    intNullOption;
  inherit (helpers.converter)
    attrKeysToSnake;
  inherit (helpers.utils)
    activated
    activatedConfig
    activatedPackages
    removeEnable;

  inherit (lib)
    mapAttrs
    mapAttrsToList
    mkEnableOption
    mkOption;

  inherit (lib.types)
    attrsOf
    anything
    str
    submodule
    nullOr
    listOf;

  # template for source options
  mkSourceOption = name: attr:
    mkOption {
      type = submodule {
        options = {
          enable = mkEnableOption "";
          priority = intNullOption "";
          entryFilter = rawLuaOption null ''
            A source-specific entry filter, with the following function signature:
            >
              function(entry: cmp.Entry, ctx: cmp.Context): boolean
            <

              Returning `true` will keep the entry, while returning `false` will remove it.

              This can be used to hide certain entries from a given source. For instance, you
              could hide all entries with kind `Text` from the `nvim_lsp` filter using the
              following source definition:
            >lua
              {
                name = 'nvim_lsp',
                entry_filter = function(entry, ctx)
                  return require('cmp.types').lsp.CompletionItemKind[entry:get_kind()] ~= 'Text'
                end
              }
            <
              Using the `ctx` parameter, you can further customize the behaviour of the
              source.
          '';
          option = mkOption {
            type = nullOr (attrsOf anything);
            description = "If direct lua code is needed use helpers.mkRaw";
            default = null;
          };
          triggerCharacters = mkOption {
            type = nullOr (listOf str);
            default = null;
          };
          keywordLength = intNullOption "";
          keywordPattern = intNullOption "";
          maxItemCount = intNullOption "";
          groupIndex = intNullOption "";
        };
      };
      description = "Module for the ${name} source for nvim-cmp";
      default = { };
    };

  # list of sources
  sourcesSet = with pkgs.vimExtraPlugins; {
    buffer = { packages = [ cmp-buffer ]; };
    calc = { packages = [ cmp-calc ]; };
    cmdline = { packages = [ cmp-cmdline ]; };
    cmp-clippy = { packages = [ cmp-clippy ]; };
    cmp-cmdline-history = { packages = [ cmp-cmdline-history ]; };
    cmp_pandoc = { packages = [ cmp-pandoc-nvim ]; };
    cmp_tabnine = { packages = [ cmp-tabnine ]; };
    conventionalcommits = { packages = [ cmp-conventionalcommits ]; };
    copilot = { packages = [ cmp-copilot ]; };
    crates = { packages = [ crates-nvim ]; extraConfig = "require('crates').setup()"; };
    dap = { packages = [ cmp-dap ]; };
    dictionary = { packages = [ cmp-dictionary ]; };
    digraphs = { packages = [ cmp-digraphs ]; };
    emoji = { packages = [ cmp-emoji ]; };
    fish = { packages = [ cmp-fish ]; };
    fuzzy_buffer = { packages = [ cmp-fuzzy-buffer ]; };
    fuzzy_path = { packages = [ cmp-fuzzy-path ]; };
    git = { packages = [ cmp-git ]; };
    greek = { packages = [ cmp-greek ]; };
    latex_symbols = { packages = [ cmp-latex-symbols ]; };
    look = { packages = [ cmp-look ]; };
    luasnip = { packages = [ cmp-luasnip ]; };
    npm = { packages = [ cmp-npm ]; };
    nvim_lsp = { packages = [ cmp-nvim-lsp ]; };
    nvim_lsp_document_symbol = { packages = [ cmp-nvim-lsp-document-symbol ]; };
    nvim_lsp_signature_help = { packages = [ cmp-nvim-lsp-signature-help ]; };
    nvim_lua = { packages = [ cmp-nvim-lua ]; };
    omni = { packages = [ cmp-omni ]; };
    pandoc_references = { packages = [ cmp-pandoc-references ]; };
    path = { packages = [ cmp-path ]; };
    rg = { packages = [ cmp-rg ]; };
    snippy = { packages = [ cmp-snippy ]; };
    spell = { packages = [ cmp-spell ]; };
    tmux = { packages = [ cmp-tmux ]; };
    treesitter = { packages = [ cmp-treesitter ]; };
    ultisnips = { packages = [ cmp-nvim-ultisnips ]; };
    vim_lsp = { packages = [ cmp-vim-lsp ]; };
    vimwiki-tags = { packages = [ cmp-vimwiki-tags ]; };
    vsnip = { packages = [ cmp-vsnip ]; };
    zsh = { packages = [ cmp-zsh ]; };
  };

  # fill out missing information to source definition
  fillMissingInfo = _name: { packages, extraConfig ? "" }:
    { inherit packages extraConfig; };

  plugins = mapAttrs fillMissingInfo sourcesSet;

in {

  # nix module options for all sources
  options = mapAttrs mkSourceOption plugins;

  # list of packages that sources depend on like the cmp-source package itself.
  # packages = mapAttrsToList (name: attrs: attrs.package) (helpers.activated plugins); ## return packages of activated sources
  packages = activatedPackages cfg-sources plugins;

  # list of extra config that sources define/require
  # config = mapAttrsToList (name: attrs: attrs.extraConfig) (helpers.activated plugins); ## return packages of activated sources
  extraConfig = activatedConfig cfg-sources plugins;

  # list of the sources config for cmp
  # output format [ { ["name"] = "<name>" } ]
  config =
      mapAttrsToList
        (name: attrs: { name = name; } // (attrKeysToSnake (removeEnable attrs)) )
        (activated cfg-sources cfg-sources);

}
