{
  config,
  lib,
  pkgs,
  ...
}: {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.desktop.hyprland.enable {
    wayland.windowManager.hyprland = {
      configType = "lua";
      settings = {};
      extraConfig = builtins.replaceStrings ["@dbus@"] ["${pkgs.dbus}"] (builtins.readFile ./hyprland.lua);
    };
  };
}
