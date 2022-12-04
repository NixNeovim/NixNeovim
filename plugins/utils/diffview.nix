{ pkgs, lib, config, ... }:

with lib;

let

  name = "diffview";
  pluginUrl = "https://github.com/sindrets/diffview.nvim";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
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
    (if cfg.useIcons then nvim-web-devicons else null)
  ];
}
