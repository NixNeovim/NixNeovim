{ pkgs, lib, config, ... }:

with lib;

let

  name = "diffview";

  helpers = import ../helpers.nix { inherit lib config; };
  cfg = config.programs.nixvim.plugins.${name};

  moduleOptions = with helpers; {
    diffBinaries = boolOption false "Show diffs for binaries";
    watchIndex = boolOption true "Update views and index buffers when the git index changes";
  };

  pluginOptions = helpers.toLuaOptions cfg moduleOptions;

in with helpers;
mkLuaPlugin {
  inherit name moduleOptions;
  description = "Enable ${name}.nvim";
  extraPlugins = with pkgs.vimExtraPlugins; [
    diffview-nvim
    plenary-nvim
  ]; # ++ optional cfg.useIcons nvim-web-devicons;
  extraConfigLua = "require('${name}').setup ${toLuaObject pluginOptions}";
}
