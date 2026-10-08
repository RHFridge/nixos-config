# `ide [dir]` — a VS Code-ish workspace in one terminal:
#
#   ┌ files (yazi) ┬──────────── editor (helix) ─────────────┐
#   │              │                                          │
#   │  Enter opens │                                          │
#   │  file in →   │                                          │
#   └──────────────┴──────────────────────────────────────────┘
#   Alt+g lazygit (floating)   Alt+f scratch terminal (floating)
#   Alt+h / Alt+l jump between sidebar and editor
#
# Running `ide` again in the same folder re-attaches to the same session.
{
  config,
  lib,
  pkgs,
  ...
}: let
  user = config.vars.user;
  hmCfg = config.home-manager.users.${user};
  toml = pkgs.formats.toml {};

  # Called by the sidebar yazi: focus the editor pane and tell Helix to open
  # the file(s). Works because the sidebar is always the left-most pane.
  ide-open = pkgs.writeShellApplication {
    name = "ide-open";
    runtimeInputs = [hmCfg.programs.zellij.package pkgs.coreutils];
    text = ''
      if [ -z "''${ZELLIJ:-}" ]; then
        exec "''${EDITOR:-hx}" "$@"
      fi
      zellij action move-focus right
      for f in "$@"; do
        # Single quotes = literal in Helix's command line (no % expansion).
        if [[ "$f" == *"'"* ]]; then q="\`$f\`"; else q="'$f'"; fi
        zellij action write 27        # Esc -> normal mode
        sleep 0.05
        zellij action write-chars ":open $q"
        zellij action write 13        # Enter
      done
    '';
  };

  ide = pkgs.writeShellApplication {
    name = "ide";
    runtimeInputs = [hmCfg.programs.zellij.package pkgs.coreutils pkgs.gnugrep];
    text = ''
      dir="$(realpath "''${1:-.}")"
      cd "$dir"
      name="$(basename "$dir")"
      name="''${name//[^A-Za-z0-9_-]/_}"

      if [ -n "''${ZELLIJ:-}" ]; then
        # Already inside Zellij: open the project as a new tab instead.
        exec zellij action new-tab --layout ide --cwd "$dir" --name "$name"
      fi

      if zellij list-sessions --short --no-formatting 2>/dev/null | grep -qx "$name"; then
        exec zellij attach "$name"
      fi
      exec zellij --session "$name" --new-session-with-layout ide
    '';
  };

  # Narrow, single-column yazi for the sidebar. Separate config dir so your
  # normal `yazi` / `y` keeps its three columns.
  sidebarYazi = {
    "yazi-sidebar/yazi.toml".source = toml.generate "yazi-sidebar.toml" {
      mgr = {
        ratio = [0 1 0];
        show_hidden = false;
        sort_dir_first = true;
        linemode = "none";
      };
      opener.edit = [
        {
          run = "ide-open %s";
          desc = "Open in Helix (IDE)";
          for = "unix";
        }
      ];
    };
    "yazi-sidebar/theme.toml".source = toml.generate "yazi-sidebar-theme.toml" hmCfg.programs.yazi.theme;
  };
in {
  home-manager.users.${user} = lib.mkIf config.modules.programs.editors.ide.enable {
    home.packages = [ide ide-open];

    xdg.configFile = sidebarYazi;

    programs.zellij.layouts.ide = ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="zellij:compact-bar"
              }
          }
          tab name="code" focus=true {
              pane split_direction="vertical" {
                  pane name="files" size="18%" command="env" {
                      args "YAZI_CONFIG_HOME=${config.home-manager.users.${user}.xdg.configHome}/yazi-sidebar" "yazi"
                  }
                  pane name="editor" size="82%" focus=true command="hx"
              }
          }
      }
    '';
  };
}
