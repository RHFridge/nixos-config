{
  pkgs,
  config,
  lib,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.editors.dbeaver.enable {
    programs.dbeaver = {
      enable = true;
    };
  };
}
