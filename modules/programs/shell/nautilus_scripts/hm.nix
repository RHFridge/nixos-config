{
  config,
  lib,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.shell.nautilusScripts.enable {
    xdg.configFile."nautilus/scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };
}
