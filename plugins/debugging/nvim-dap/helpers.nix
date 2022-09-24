{ pkgs, config, lib, ... }:

with lib;
with types;
let

  enabledAdapter = cfg:
    let
      isActive = serverName: _options: !(isNull cfg.${serverName}) && cfg.${serverName}.enable;
    in filterAttrs isActive servers;

in rec {

  # create the lua code to activate the lsp server
  adapterToLua = cfg:
    mapAttrsToList (adapter: adapterAttrs:
      let
        language = "rust";

        wrapped-setup = "local __setup = ${runWrappers setupWrappers "{
          on_attach = __on_attach,
          ${cfg.${server}.extraConfig}
        }"}";
      in ''
          do -- adapter config (${adapter})
            require('dap').adapters.${language} {
              ${}
            }
          end -- lsp server config ${server}
        '') (enabledServers cfg);

}
