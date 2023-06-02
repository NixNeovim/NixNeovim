{ pkgs, config, lib, ... }@args:
let
  helpers = import ./helpers.nix { inherit pkgs lib config; };
  serverData = {
    code_actions = { 
      eslint.packages = [ pkgs.nodePackages.eslint ];
      eslint_d.packages = [ pkgs.eslint_d ];
      gitsigns.packages = [ pkgs.luajitPackages.gitsigns-nvim ];
      gomodifytags.packages = [ pkgs.gomodifytags ];
      impl.packages = [ pkgs.impl ];
      ltrs.packages = [ pkgs.languagetool-rust ];
      proselint.packages = [ pkgs.proselint ];
      # refactoring.packages = [ pkgs.vimPlugins.refactoring-nvim ];
      shellcheck.packages = [ pkgs.shellcheck ];
      statix.packages = [ pkgs.statix ];
      # ts_node_action.packages = [ ];
      # xo.packages = [ ];
    };
    completion = {
      # luasnip.packages = [ pkgs.vimPlugins.luasnip ];
      spell.packages = [ ];
      tags.packages = [ ];
      # vsnip.packages = [ ];
    };
    diagnostics = {
      actionlint.packages = [ pkgs.actionlint ];
      alex.packages = [ pkgs.nodePackages.alex ];
      ansiblelint.packages = [ pkgs.ansible-lint ];
      # bslint.packages = [ ];
      buf.packages = [ pkgs.buf ];
      # buildifier.packages = [ ];
      # cfn_lint.packages = [ ];
      # checkmake.packages = [ ];
      # checkstyle.packages = [ ];
      # chktex.packages = [ ];
      # clang_check.packages = [ ];
      # clazy.packages = [ ];
      # clj_kondo.packages = [ ];
      # cmake_lint.packages = [ ];
      # codespell.packages = [ ];
      # commitlint.packages = [ ];
      # cppcheck.packages = [ ];
      # cpplint.packages = [ ];
      # credo.packages = [ ];
      # cspell.packages = [ ];
      # cue_fmt.packages = [ ];
      # curlylint.packages = [ ];
      # deadnix.packages = [ ];
      # .packages = [ ];
    };
    formatting = {
      alejandra = {
        packages = [ pkgs.alejandra ];
      };
      nixfmt = {
        packages = [ pkgs.nixfmt ];
      };
      prettier = {
        packages = [ pkgs.nodePackages.prettier ];
      };
      flake8 = {
        packages = [ pkgs.python3Packages.flake8 ];
      };
    };
  };
  # Format the servers to be an array of attrs like the following example
  # [{
  #   name = "prettier";
  #   sourceType = "formatting";
  #   packages = [...];
  # }]
  serverDataFormatted = lib.mapAttrsToList
    (sourceType: sourceSet:
      lib.mapAttrsToList (name: attrs: attrs // { inherit sourceType name; }) sourceSet
    )
    serverData;
  dataFlattened = lib.flatten serverDataFormatted;
in
{
  imports = lib.lists.map (helpers.mkServer) dataFlattened;
}
