{
  lib,
  helpers,
  ...
}:
with lib;
with helpers; {
  showIcons = boolOption true "Whether to show file icons (requires 'kyazdani42/nvim-web-devicons')";
  setVimSettings = boolOption true "Whether to set Vim's settings for tabline (make it always shown and allow hidden buffers)";
  tabpageSection = enumOption ["left" "right" "none"] "left" "Where to show tabpage section in cae of multiple vim tabpages";
}
