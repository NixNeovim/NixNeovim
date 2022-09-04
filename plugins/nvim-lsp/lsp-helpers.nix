{ pkgs, config, lib, ... }:

with lib;
with types;
let
  helpers = import ../helpers.nix { inherit lib config; };
  servers = import ./servers.nix { inherit pkgs; };


  ## add wrapper functions to lua lsp config
  runWrappers = wrappers: s:
    if wrappers == [] then s
    else (head wrappers) (runWrappers (tail wrappers) s);

  enabledServers = cfg:
    let
      isActive = serverName: _options: !(isNull cfg.${serverName}) && cfg.${serverName}.enable;
    in filterAttrs isActive servers;


in rec {

  # input is entry from lsp-servers list (with key/name and value) and fills in all missing information
  fullAttrs = server: {
    languages ? "(nothing specified)",
    packages ? [ pkgs.${server} ],
    serverName ? server}: { inherit languages packages serverName; };

  # create the lua code to activate the lsp server
  serversToLua = cfg: setupWrappers:
     mapAttrsToList (server: serverAttrs:
      let

        fullServerAttrs = fullAttrs server serverAttrs;
        serverName = fullServerAttrs.serverName;
          
        onAttach =
          ''
          local __on_attach = function(client, bufnr)
            ${cfg.${server}.onAttachExtra}
          end
        '';

        wrapped-setup = "local __setup = ${runWrappers setupWrappers "{
          on_attach = __on_attach,
          ${cfg.${server}.extraConfig}
        }"}";
      in ''
          do -- lsp server config ${server}
            ${onAttach}
            ${wrapped-setup}
            require('lspconfig')["${serverName}"].setup(__setup)
          end -- lsp server config ${server}
        '') (enabledServers cfg);

    # mapAttrsToList (serverName: _options:
    #   let


    #   in if isNull servers.${serverName} then ""
    #     else if servers.${serverName}.enable then
    #     else "") servers;

  # returns a list of all packages of all activated lsp servers
  # TODO: combine with cmp sources helper functions
  lspPackages = cfg:
    let

      # get requried packages of lsp-server
      getPackage = server: serverAttrs:
        if isNull serverAttrs.packages then
          [ pkgs.${server} ]
        else serverAttrs.packages;

      packageList = mapAttrsToList getPackage (enabledServers cfg);

    in flatten packageList;
    
    # let
    #   packageList = mapAttrsToList (sourceName: _option:
    #     if isNull attrs.${sourceName} then
    #       null
    #     else if attrs.${sourceName}.enable then
    #       let
    #         value = sourceNameAndPlugin.${sourceName};
    #         package =
    #           if isString value then
    #             value
    #           else
    #             value.package;
    #       in pkgs.vimExtraPlugins.${package}
    #     else
    #       null
    #     ) attrs;
    # in filter (p: !(isNull p)) packageList;


  # mkLsp = { name
  #   , languages ? "Enable ${name}."
  #   , serverName ? name
  #   , packages ? [ pkgs.${name} ]
  #   , ... }:

  #     # returns a module
  #     { pkgs, config, lib, ... }:
  #       let
  #         cfg = config.programs.nixvim.plugins.lsp.servers.${name};
  #       in
  #       {
  #         options = {
  #           programs.nixvim.plugins.lsp.servers.${name} = {
  #             enable = mkEnableOption languages;
  #           };
  #         };

  #         config = mkIf cfg.enable {
  #           programs.nixvim.extraPackages = packages;

  #           programs.nixvim.plugins.lsp.enabledServers = [ serverName ];
  #         };
  #       };
}
