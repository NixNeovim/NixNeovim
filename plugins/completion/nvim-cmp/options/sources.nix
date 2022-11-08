{ lib, config, pkgs, ... }:

with lib;
with types;
with pkgs.vimExtraPlugins;

let

  helpers = import ../../../helpers.nix { inherit lib config; };

  # template for source options
  mkSourceOption = name: attr:
    mkOption {
      type = submodule {
        options = with helpers; {
          enable = mkEnableOption "";
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
          priority = intNullOption "";
          maxItemCount = intNullOption "";
          groupIndex = intNullOption "";
        };
      };
      description = "Module for the ${name} (${attr.package}) source for nvim-cmp";
      default = {};
    };

  # list of sources
  sourcesSet = {
    buffer                   = { package = cmp-buffer; };
    calc                     = { package = cmp-calc; };
    cmdline                  = { package = cmp-cmdline; };
    cmp-clippy               = { package = cmp-clippy; };
    cmp-cmdline-history      = { package = cmp-cmdline-history; };
    cmp_pandoc               = { package = cmp-pandoc-nvim; };
    cmp_tabnine              = { package = cmp-tabnine; };
    conventionalcommits      = { package = cmp-conventionalcommits; };
    copilot                  = { package = cmp-copilot; };
    crates                   = { package = crates-nvim; extraConfig = "require('crates').setup()"; };
    dap                      = { package = cmp-dap; };
    dictionary               = { package = cmp-dictionary; };
    digraphs                 = { package = cmp-digraphs; };
    emoji                    = { package = cmp-emoji; };
    fish                     = { package = cmp-fish; };
    fuzzy_buffer             = { package = cmp-fuzzy-buffer; };
    fuzzy_path               = { package = cmp-fuzzy-path; };
    git                      = { package = cmp-git; };
    greek                    = { package = cmp-greek; };
    latex_symbols            = { package = cmp-latex-symbols; };
    look                     = { package = cmp-look; };
    luasnip                  = { package = cmp-luasnip; };
    npm                      = { package = cmp-npm; };
    nvim_lsp                 = { package = cmp-nvim-lsp; };
    nvim_lsp_document_symbol = { package = cmp-nvim-lsp-document-symbol; };
    nvim_lsp_signature_help  = { package = cmp-nvim-lsp-signature-help; };
    nvim_lua                 = { package = cmp-nvim-lua; };
    omni                     = { package = cmp-omni; };
    pandoc_references        = { package = cmp-pandoc-references; };
    path                     = { package = cmp-path; };
    rg                       = { package = cmp-rg; };
    snippy                   = { package = cmp-snippy; };
    spell                    = { package = cmp-spell; };
    tmux                     = { package = cmp-tmux; };
    treesitter               = { package = cmp-treesitter; };
    ultisnips                = { package = cmp-nvim-ultisnips; };
    vim_lsp                  = { package = cmp-vim-lsp; };
    vimwiki-tags             = { package = cmp-vimwiki-tags; };
    vsnip                    = { package = cmp-vsnip; };
    zsh                      = { package = cmp-zsh; };
  };

  # fill out missing information to source definition
  fillMissingInfo = _name: { package, extraConfig ? "" }:
    { inherit package extraConfig; };

  plugins = mapAttrs fillMissingInfo sourcesSet;

  activated = cfg: filterAttrs (name: attrs: cfg.${name}.enable) plugins; # filter activted sources

in {

  # nix module options for all sources
  options = mapAttrs mkSourceOption plugins;

  # list of packages that sources depend on like the cmp-source package itself.
  packages = cfg-sources:
    mapAttrsToList (name: attrs: attrs.package) (activated cfg-sources); ## return packages of activated sources

  # list of extra config that sources define/require
  config = cfg-sources:
    mapAttrsToList (name: attrs: attrs.extraConfig) (activated cfg-sources); ## return packages of activated sources

}
