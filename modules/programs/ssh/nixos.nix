{
  config,
  lib,
  ...
}: let
  cfg = config.modules.programs.ssh;
  user = config.users.users.${config.vars.user};
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      sops.secrets."ssh/hosts" = {
        mode = "0400";
        owner = user.name;
        group = user.group;
      };
    })

    (lib.mkIf cfg.server.enable {
      services.openssh = {
        enable = true;
        ports = cfg.server.ports;
        openFirewall = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [ config.vars.user ];
        };
      };

      users.users.${config.vars.user}.openssh.authorizedKeys.keys = cfg.server.authorizedKeys;
    })
  ];
}
