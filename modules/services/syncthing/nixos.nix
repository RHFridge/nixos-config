{ lib, config, pkgs, ... }:
let
  st = config.services.syncthing;
  homeServerId = "SFS3MRC-FADS62R-3UCULXM-3K76X3D-CC7NNA6-SKS3WLP-SRGMZN7-RNTRMA3";
  addrSecret = config.sops.secrets."homeserver-address".path;
in {
  config = lib.mkIf config.modules.services.syncthing.enable {
    sops.secrets."homeserver-address".owner = config.vars.user;

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = config.vars.user;
      group = "users";
      configDir = "/home/${config.vars.user}/.config/syncthing";
      dataDir = "/home/${config.vars.user}/.config/syncthing";
      key = config.sops.secrets."${config.vars.host}/syncthing/key".path;
      cert = config.sops.secrets."${config.vars.host}/syncthing/cert".path;
      settings = {
        options = {
          natEnabled = false;
        };
        devices = {
          "HomeServer" = {
            id = homeServerId;
          };
        };

        folders = {
          "Personal" = {
            path = "~/KeePass/Personal";
            devices = [ "HomeServer" ];
            ignorePerms = true;
          };

          "Home" = {
            path = "~/KeePass/Home";
            devices = [ "HomeServer" ];
            ignorePerms = true;
          };

          "Sops" = {
            path = "~/.config/sops/age/";
            devices = [ "HomeServer" ];
            ignorePerms = true;
          };
        };
      };
    };
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    # Patch HomeServer's address in from sops after syncthing-init applies the Nix settings
    systemd.services.syncthing-homeserver-address = {
      description = "Set Syncthing HomeServer address from sops secret";
      after = [ "syncthing.service" "syncthing-init.service" ];
      wantedBy = [ "syncthing-init.service" "multi-user.target" ];
      path = with pkgs; [ curl jq libxml2 ];
      serviceConfig = {
        Type = "oneshot";
        User = st.user;
      };
      script = ''
        set -euo pipefail
        host=$(< ${addrSecret})
        apikey=$(xmllint --xpath 'string(configuration/gui/apikey)' ${st.configDir}/config.xml)

        jq -n --arg h "$host" '{addresses: ["tcp://\($h):22000", "quic://\($h):22000", "dynamic"]}' \
          | curl -sSf -X PATCH \
              -H "X-API-Key: $apikey" -H "Content-Type: application/json" \
              --retry 30 --retry-delay 1 --retry-all-errors \
              -d @- "http://${st.guiAddress}/rest/config/devices/${homeServerId}"
      '';
    };
  };
}