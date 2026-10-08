{
  lib,
  pkgs,
  config,
  ...
}: let
  home = config.home-manager.users.${config.vars.user}.home.homeDirectory;

  # Settings shared by qt5ct and qt6ct. The icon theme is what fixes the
  # light-theme icons in VLC / kid3: without it Qt falls back to icons drawn
  # for light backgrounds. Home Manager owns these files now, so change
  # things here rather than in the qt5ct / qt6ct apps.
  qtctAppearance = {
    custom_palette = true;
    icon_theme = "WhiteSur-dark";
    # "default" = Qt's own file dialog, "xdgdesktopportal" = GTK file picker
    standard_dialogs = "default";
    style = "kvantum-dark";
  };
  qtctInterface = {
    activate_item_on_single_click = 1;
    dialog_buttons_have_icons = 1;
    double_click_interval = 400;
    keyboard_scheme = 2;
    menus_have_icons = true;
    show_shortcuts_in_context_menus = true;
    toolbutton_style = 4;
    underline_shortcut = 1;
    wheel_scroll_lines = 3;
  };
in {
  home-manager.users.${config.vars.user} = lib.mkIf config.modules.desktop.framework.stylix.enable {
    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland;xcb";
      # Let Hyprland draw decorations, not Qt.
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    qt = {
      enable = true;
      # "qtct" exports QT_QPA_PLATFORMTHEME=qt5ct, which both qt5ct (Qt5 apps
      # like VLC) and qt6ct (Qt6 apps) answer to. The old "qt6ct" value left
      # Qt5 apps with no platform theme at all.
      platformTheme.name = "qtct";
      # Kvantum with a forced dark palette (also exported as QT_STYLE_OVERRIDE)
      style = {
        name = "kvantum-dark";
        package = [
          pkgs.libsForQt5.qtstyleplugin-kvantum
          pkgs.qt6Packages.qtstyleplugin-kvantum
        ];
      };

      qt5ctSettings = {
        Appearance = qtctAppearance // {
          color_scheme_path = "${home}/.config/qt5ct/style-colors.conf";
        };
        Fonts = {
          general = ''"DejaVu Sans,12,-1,5,50,0,0,0,0,0"'';
          fixed = ''"DejaVu Sans,12,-1,5,50,0,0,0,0,0"'';
        };
        Interface = qtctInterface // {
          buttonbox_layout = 0;
          cursor_flash_time = 1000;
        };
        Troubleshooting.force_raster_widgets = 1;
      };

      qt6ctSettings = {
        Appearance = qtctAppearance // {
          color_scheme_path = "${home}/.config/qt6ct/style-colors.conf";
        };
        Fonts = {
          general = ''"Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"'';
          fixed = ''"Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"'';
        };
        Interface = qtctInterface // {
          buttonbox_layout = 3;
          cursor_flash_time = 1200;
        };
        Troubleshooting.force_raster_widgets = 1;
      };
    };

    xdg.configFile = {
      # WhiteSur dark palettes for qt5ct / qt6ct (qt6 has one extra accent colour)
      "qt5ct/style-colors.conf".source = ./qtct/qt5ct-colors.conf;
      "qt6ct/style-colors.conf".source = ./qtct/qt6ct-colors.conf;

      # WhiteSur Kvantum theme: artwork from the package, our own config with
      # translucency/blur off (Hyprland doesn't blur behind Qt windows, so the
      # stock translucent look comes out muddy).
      "Kvantum/WhiteSur/WhiteSurDark.svg".source = "${pkgs.whitesur-kde}/share/Kvantum/WhiteSur/WhiteSurDark.svg";
      "Kvantum/WhiteSur/WhiteSurDark.kvconfig".source = ./kvantum/WhiteSurDark.kvconfig;
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=WhiteSurDark
      '';
    };
  };
}
