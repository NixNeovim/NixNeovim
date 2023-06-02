{ pkgs, config, lib, ... }@args:
let
  helpers = import ./helpers.nix { inherit pkgs lib config; };
  serverData = {
    completion = { };
    diagnostics = { };
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
