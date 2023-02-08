{ pkgs, lib, config, ... }:

with lib;

let

  helpers = import ./helpers.nix { inherit lib config; };

  # names inserted here must match the name of the package in pkgs.vimExtraPlugins
  # default for setup is 'false'
  # TODO: create modules for these
  plugs = with pkgs.vimExtraPlugins; [
    "vim-printer"
    "vim-easy-align"
    "gruvbox"
    "nest-nvim"
    "plenary-nvim"
    "nvim-ts-context-commentstring"
    "indent-blankline-nvim"
    "asyncrun-vim"
    "ltex-extra-nvim"
    "firenvim"
    { name = "vim-startuptime"; setup = false; }
    { name = "lsp-signature-nvim"; setup = false; }
  ];

  fillAttrs = { name, packageName ? name, setup ? false }: { inherit name packageName setup; };

in
with helpers; {
  imports = lib.forEach plugs
    (p:
      let

        plugin =
          if isString p then
            { name = p; packageName = p; setup = false; }
          else
            fillAttrs p;

        setupString =
          if plugin.setup then
            "require('${plugin.name}').setup()"
          else
            "";

        # setupString =
        #   if isString p then
        #     ""
        #   else
        #     if isString p.setup then
        #       p.setup
        #     else if p.setup then
        #       "require('${name}').setup()"
        #     else "";

      in
      mkLuaPlugin {
        name = plugin.name;
        extraDescription = "This module was auto-generated";
        extraPlugins = [ pkgs.vimExtraPlugins.${plugin.packageName} ];
        extraConfigLua = setupString;
      }
    );
}
