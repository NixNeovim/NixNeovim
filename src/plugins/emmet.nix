{ lib, pkgs, helpers, config }:
with lib;
let

  inherit (helpers.deprecated)
    mkDefaultOpt
    mkPlugin;

  eitherAttrsStrInt = with types;
    let
      strInt = either str int;
    in either strInt (attrsOf (either strInt (attrsOf strInt)));

in mkPlugin { inherit config lib; } {
  name = "emmet";
  description = "Enable emmet";
  extraPlugins = [ pkgs.vimPlugins.emmet-vim ];

  options = {
    mode = mkDefaultOpt {
      type = types.enum [ "i" "n" "v" "a" ];
      global = "user_emmet_mode";
      description = "Mode where emmet will enable";
    };

    leader = mkDefaultOpt {
      type = types.str;
      global = "user_emmet_leader_key";
      description = "Set leader key";
    };

    settings = mkDefaultOpt {
      type = types.attrsOf (types.attrsOf eitherAttrsStrInt);
      global = "user_emmet_settings";
      description = "Emmet settings";
    };
  };
}
