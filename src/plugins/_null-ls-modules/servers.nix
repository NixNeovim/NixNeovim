{ pkgs, config, lib, super }:
let

  serverData = {
    code_actions = { };
    completion = { };
    diagnostics = { };
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
  imports = lib.lists.map (super.helpers.mkServer) dataFlattened;
}
