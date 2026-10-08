{
  lib,
  config,
  pkgs-unstable,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.programs.multimedia.krita.enable {
    home.packages = with pkgs-unstable; [
      krita
    ];
  };
}
