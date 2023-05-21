{ pkgs, lib, config, ... }:

with lib;

let

  helpers = import ../helper { inherit pkgs lib config; };

  # names inserted here must match the name of the package in pkgs.vimExtraPlugins
  # default for setup is 'false'
  # TODO: create modules for these
  plugs = [
    { name = "vim-printer"; pluginUrl = "https://github.com/meain/vim-printer"; }
    { name = "vim-easy-align"; pluginUrl = "https://github.com/junegunn/vim-easy-align"; }
    { name = "gruvbox"; pluginUrl = "https://github.com/morhetz/gruvbox"; }
    { name = "nest-nvim"; pluginUrl = "https://github.com/LionC/nest.nvim"; }
    { name = "plenary-nvim"; pluginUrl = "https://github.com/nvim-lua/plenary.nvim"; }
    { name = "indent-blankline-nvim"; pluginUrl = "https://github.com/lukas-reineke/indent-blankline.nvim"; }
    { name = "asyncrun-vim"; setup = false; pluginUrl = "https://github.com/skywind3000/asyncrun.vim"; }
    { name = "ltex-extra-nvim"; pluginUrl = "https://github.com/barreiroleo/ltex_extra.nvim"; }
    { name = "firenvim"; pluginUrl = "https://github.com/glacambre/firenvim"; }
    { name = "vim-startuptime"; setup = false; pluginUrl = "https://github.com/dstein64/vim-startuptime"; }
    { name = "lsp-signature-nvim"; setup = false; pluginUrl = "https://github.com/ray-x/lsp_signature.nvim"; }
  ];

  fillPlugin = { name, packageName ? name, setup ? false, pluginUrl }: { inherit name packageName setup pluginUrl; };

in
with helpers; {
  imports = lib.forEach plugs
    (p:
      let

        plugin = fillPlugin p;

        # setupString =
        #   if plugin.setup then
        #     "require('${plugin.name}').setup()"
        #   else
        #     "";

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
        inherit (plugin) name pluginUrl;
        extraDescription = "This module was auto-generated";
        extraPlugins = [ pkgs.vimExtraPlugins.${plugin.packageName} ];
        defaultRequire = plugin.setup;
      }
    );
}
