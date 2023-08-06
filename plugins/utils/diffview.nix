{ pkgs, lib, config, ... }:

with lib;

let

  name = "diffview";
  pluginUrl = "https://github.com/sindrets/diffview.nvim";

  helpers = import ../../helper { inherit pkgs lib config; };
  cfg = config.programs.nixneovim.plugins.${name};

  inherit (helpers.customOptions) boolOption;

  moduleOptions = {
    diffBinaries = boolOption false "Show diffs for binaries";
    watchIndex = boolOption true "Update views and index buffers when the git index changes";
    useIcons = boolOption true "Requires nvim-web-devicons";
  };


in
with helpers;
mkLuaPlugin {
  inherit name moduleOptions pluginUrl;
  extraPlugins = with pkgs.vimExtraPlugins; [
    diffview-nvim
  ];
  extraPackages = with pkgs.vimExtraPlugins; [
    diffview-nvim
    plenary-nvim
  ] ++ optional (cfg.useIcons != null && cfg.useIcons) nvim-web-devicons;
}
