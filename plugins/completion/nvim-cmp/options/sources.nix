{ lib, config, pkgs, ... }:

with lib;
with types;
with pkgs.vimExtraPlugins;

let

  cfg-plugin = config.programs.nixvim.plugins.nvim-cmp.sources;
  helpers = import ../../../helpers.nix { inherit lib config cfg-plugin; };

  # template for source options
  mkSourceOption = name: attr:
    mkOption {
      type = submodule {
        options = with helpers; {
          enable = mkEnableOption "";
          # FIX: those optoins are not considerd
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
    buffer                   = { packages = [ cmp-buffer ];  };
    calc                     = { packages = [ cmp-calc ]; };
    cmdline                  = { packages = [ cmp-cmdline ]; };
    cmp-clippy               = { packages = [ cmp-clippy ]; };
    cmp-cmdline-history      = { packages = [ cmp-cmdline-history ]; };
    cmp_pandoc               = { packages = [ cmp-pandoc-nvim ]; };
    cmp_tabnine              = { packages = [ cmp-tabnine ]; };
    conventionalcommits      = { packages = [ cmp-conventionalcommits ]; };
    copilot                  = { packages = [ cmp-copilot ]; };
    crates                   = { packages = [ crates-nvim ]; extraConfig = "require('crates').setup()"; };
    dap                      = { packages = [ cmp-dap ]; };
    dictionary               = { packages = [ cmp-dictionary ]; };
    digraphs                 = { packages = [ cmp-digraphs ]; };
    emoji                    = { packages = [ cmp-emoji ]; };
    fish                     = { packages = [ cmp-fish ]; };
    fuzzy_buffer             = { packages = [ cmp-fuzzy-buffer ]; };
    fuzzy_path               = { packages = [ cmp-fuzzy-path ]; };
    git                      = { packages = [ cmp-git ]; };
    greek                    = { packages = [ cmp-greek ]; };
    latex_symbols            = { packages = [ cmp-latex-symbols ]; };
    look                     = { packages = [ cmp-look ]; };
    luasnip                  = { packages = [ cmp-luasnip ]; };
    npm                      = { packages = [ cmp-npm ]; };
    nvim_lsp                 = { packages = [ cmp-nvim-lsp ]; };
    nvim_lsp_document_symbol = { packages = [ cmp-nvim-lsp-document-symbol ]; };
    nvim_lsp_signature_help  = { packages = [ cmp-nvim-lsp-signature-help ]; };
    nvim_lua                 = { packages = [ cmp-nvim-lua ]; };
    omni                     = { packages = [ cmp-omni ]; };
    pandoc_references        = { packages = [ cmp-pandoc-references ]; };
    path                     = { packages = [ cmp-path ]; };
    rg                       = { packages = [ cmp-rg ]; };
    snippy                   = { packages = [ cmp-snippy ]; };
    spell                    = { packages = [ cmp-spell ]; };
    tmux                     = { packages = [ cmp-tmux ]; };
    treesitter               = { packages = [ cmp-treesitter ]; };
    ultisnips                = { packages = [ cmp-nvim-ultisnips ]; };
    vim_lsp                  = { packages = [ cmp-vim-lsp ]; };
    vimwiki-tags             = { packages = [ cmp-vimwiki-tags ]; };
    vsnip                    = { packages = [ cmp-vsnip ]; };
    zsh                      = { packages = [ cmp-zsh ]; };
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
  packages = helpers.activatedPackages plugins;

  # list of extra config that sources define/require
  # config = mapAttrsToList (name: attrs: attrs.extraConfig) (helpers.activated plugins); ## return packages of activated sources
  config = helpers.activatedConfig plugins;

}
